class ClientPayment < ActiveRecord::Base

  attr_accessible :amount_paid, :bank_name, :client_invoice_id, :paid_date, :payment_mode, :transaction_reference, :credited_at

  has_paper_trail

  module PaymentMode
    NEFT = 'neft'
    RTGS = 'rtgs'
    CHECK = 'check'
    ALL = [NEFT, RTGS, CHECK]
  end

  # Associations
  belongs_to :client_invoice

  # Validations
  validates :client_invoice, :amount_paid, :bank_name, :paid_date, :payment_mode, :transaction_reference, :presence => true
  validates :amount_paid, :numericality => {:greater_than => 0}
  validates :credited_at, :presence => true, :if => :persisted?

  # CallBacks
  after_save :send_notification

  def points_credited?
    client_invoice.points_upload? && is_paid? && client_invoice.points > 0
  end

  def is_paid?
    credited_at.present?
  end

  private

  def send_notification
    if self.points_credited?
      self.client_invoice.client.client_point_credits.create!(points: self.client_invoice.points)
    end
    params = {status: is_paid? ? ClientInvoice::Status::CONFIRMED : ClientInvoice::Status::PROCESSING}
    params.merge!(inv_sequence: self.client_invoice.next_sequence) if is_paid?
    self.client_invoice.update_attributes(params)
    ClientPaymentNotifier.notify(self)
  end

end
