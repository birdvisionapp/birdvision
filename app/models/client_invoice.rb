class ClientInvoice < ActiveRecord::Base

  include ViewsHelper
  
  attr_accessible :client_id, :due_date, :invoice_type, :invoice_date, :points, :amount_breakup, :status, :inv_sequence, :deleted

  has_paper_trail

  serialize :amount_breakup, JSON

  module InvoiceType
    MONTHLY_RETAINER = 'monthly_retainer'
    POINTS_UPLOAD = 'points_upload'
    ALL = [MONTHLY_RETAINER, POINTS_UPLOAD]
  end

  module Status
    PENDING = 'pending'
    PROCESSING = 'processing'
    CONFIRMED = 'confirmed'
    ALL = [PENDING, PROCESSING, CONFIRMED]
  end

  # Scopes
  scope :available, where(deleted: false)
  [:pending, :processing, :confirmed].each do |status|
    scope status, where(status: status)
  end

  # Associations
  belongs_to :client
  has_one :client_payment, :dependent => :destroy

  # Validations
  validates :client, :points, :presence => true
  validates :points, :numericality => {:greater_than => 0}, :if => lambda { |c| c.invoice_type == ClientInvoice::InvoiceType::POINTS_UPLOAD }

  # CallBacks
  before_create :calculate_amount
  after_create :send_notification

  BVC_VOUCHERS_LABEL = "BVC Rewards E-Vouchers / Points"
  BVC_MONTHLY_RETAINER_LABEL = "Monthly Retainer for the month of"

  def description
    case(invoice_type)
    when ClientInvoice::InvoiceType::MONTHLY_RETAINER
      "#{BVC_MONTHLY_RETAINER_LABEL} #{invoice_date.strftime("%B %Y")}"
    when ClientInvoice::InvoiceType::POINTS_UPLOAD
      "#{BVC_VOUCHERS_LABEL}: #{points}"
    end
  end

  def breakup
    details = []
    if monthly_retainer?
      details << ['Fixed Amount (INR)', fixed_amount] if fixed_amount
      details << ['Participant Charges (INR)', "#{participant_basis} (Participants: #{users_count} x Rate: #{participant_rate})"] if participant_basis
      details << ["Service Tax @ #{SERVICE_TAX}% (INR)", "#{mr_tax} (@#{SERVICE_TAX}% of #{mr_total_amount.round})"] if SERVICE_TAX > 0
    end
    if points_upload?
      details = [[BVC_VOUCHERS_LABEL,  "#{points}"], ["Conversion Rate", "1 Rupee = #{points_ratio.round} Point(s)"], ["Rupees", points_to_rupees], ["Points Uploading Charges (INR)", "#{points_rate} (@#{puc_rate}% of #{points_to_rupees})"], ["Service Tax @ #{SERVICE_TAX}% (INR)", "#{pu_tax} (@#{SERVICE_TAX}% of #{points_rate})"]]
    end
    details
  end

  def invoice_number
    confirmed? ? "BVCR#{inv_sequence}" : "BVCPI#{id}"
  end

  def filename
    "#{invoice_label.gsub(' ', '-').downcase}-#{invoice_number}-#{invoice_type.dasherize}-#{invoice_date.strftime("%d-%m-%Y")}.pdf"
  end

  def credit_status
    (client_payment.present? && client_payment.credited_at.present?) ? humanize_date(client_payment.credited_at) : 'Waiting for Payment Credit'
  end

  def not_paid?
    !client_payment.is_paid?
  end

  def amount
    send("#{invoice_type}_final_amount")
  end

  def fixed_amount
    amount_breakup["fixed_amount"].to_i if amount_breakup["fixed_amount"].present?
  end

  def users_count
    amount_breakup["users_count"].to_i if amount_breakup["users_count"].present?
  end

  def participant_rate
    amount_breakup["participant_rate"].to_i if amount_breakup["participant_rate"].present?
  end

  def participant_basis
    (users_count * participant_rate) if users_count && participant_rate
  end

  def mr_total_amount
    fixed_amount.to_f + participant_basis.to_f
  end

  def mr_tax
    ((Float(mr_total_amount/100)*SERVICE_TAX)).round
  end

  def monthly_retainer_final_amount
    (mr_tax + mr_total_amount).round
  end

  def puc_rate
    amount_breakup["puc_rate"].present? ? amount_breakup["puc_rate"].to_f : 0
  end

  def points_rate
    return 0 unless puc_rate
    ((points_to_rupees.to_f/100)*puc_rate).round
  end

  def pu_tax
    ((points_rate.to_f/100)*SERVICE_TAX).round
  end

  def pu_charge_with_tax
    points_rate + pu_tax
  end

  def points_upload_final_amount
    rate = ((Float(points_rate.to_f/100)*SERVICE_TAX) + points_rate.to_f).round
    (points_to_rupees + rate).round
  end

  def monthly_retainer?
    invoice_type == ClientInvoice::InvoiceType::MONTHLY_RETAINER
  end
  
  def points_upload?
    invoice_type == ClientInvoice::InvoiceType::POINTS_UPLOAD
  end

  def points_to_rupees
    (points / points_ratio).round
  end

  def invoice_label
    confirmed? ? 'Invoice' : 'Pro Forma Invoice'
  end

  def confirmed?
    status == ClientInvoice::Status::CONFIRMED
  end

  def soft_delete
    update_attribute(:deleted, true)
  end

  def next_sequence
    ClientInvoice.maximum(:inv_sequence).to_i + 1
  end

  private

  def calculate_amount
    self.amount_breakup = ActiveSupport::HashWithIndifferentAccess.new(build_amount_breakup(self.invoice_type))
    self.invoice_date = Date.today unless self.invoice_date.present?
    false unless self.amount > 0
  end

  def build_amount_breakup(type)
    hash = {}
    case(type)
    when ClientInvoice::InvoiceType::MONTHLY_RETAINER
      hash.merge!(fixed_amount: self.client.fixed_amount) if self.client.is_fixed_amount?
      hash.merge!(participant_rate: self.client.participant_rate, users_count: self.client.users.select(:id).count) if self.client.is_participant_rate?
    when ClientInvoice::InvoiceType::POINTS_UPLOAD
      hash.merge!(puc_rate: self.client.puc_rate, points_ratio: client.points_to_rupee_ratio.round)
    end
    hash
  end

  def send_notification
    return nil unless self.amount > 0
    self.client.update_attribute(:expiry_date, Date.today.end_of_month.next_month)
    ClientInvoiceNotifier.notify(self)
  end

  def points_ratio
    amount_breakup["points_ratio"].present? ? amount_breakup["points_ratio"].to_f : client.points_to_rupee_ratio.to_f
  end

end
