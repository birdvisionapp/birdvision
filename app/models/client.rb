class Client < ActiveRecord::Base

  extend Admin::Reports::ClientReport

  CLIENT_KEY_LENGTH = 8

  has_one :client_customization
  has_many :client_resellers
  has_many :resellers, :through => :client_resellers
  has_many :client_managers
  has_many :access_grants, :dependent => :delete_all
  has_many :users
  belongs_to :msp
  has_many :clients_templates
  has_many :templates, :through => :clients_templates
  has_many :targeted_offer_configs


  scope :for_reseller, lambda { |reseller| joins(:client_resellers).where("client_resellers.reseller_id" => reseller.id) }
  scope :live_client, -> { where(is_live: true) }
  scope :is_sms_based, -> { where(sms_based: true) }
  scope :order_default, -> { order(:client_name) }
  scope :select_options, -> { select([:id, :client_name, :msp_id]) }
  scope :non_msp, -> { where('msp_id IS NULL') }

  has_many :schemes
  has_many :scheme_transactions
  has_many :reward_items
  has_many :client_invoices
  has_many :client_point_reports
  has_many :client_point_credits
  has_many :user_roles
  has_many :user_roles_main, :class_name => 'UserRole', :conditions => {:ancestry => nil}
  has_many :regional_managers
  has_many :representatives
  has_many :reward_product_catagories
  
  validates :client_name, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :code, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => /\A[\w-]*\Z/}
  validates :client_key, :client_secret, :uniqueness => {:case_sensitive => false}, :allow_blank => true

  belongs_to :client_catalog, :inverse_of => :client

  validates :cu_email, :cu_cc_email, :cu_phone_number, :presence => true, :if => lambda { |c| c.msp_id.present? }
  validates :contact_email, :cu_email, :cu_cc_email, :format => {:with => Devise.email_regexp}, :allow_blank => true
  validates :contact_phone_number, :cu_phone_number, :numericality => true, :allow_blank => true
  validates :points_to_rupee_ratio, :numericality => {:greater_than => 0.0}
  validates :opening_balance, :numericality => true, :allow_blank => true, :on => :create
  validates :order_approval_limit, :numericality => {:greater_than_or_equal_to => 0}, :if => lambda { |c| c.order_approval }

  attr_accessible :client_name, :contact_phone_number, :contact_email, :contact_name, :description, :cu_email, :cu_cc_email, :cu_phone_number, :settings,
    :points_to_rupee_ratio, :notes, :domain_name, :reseller_ids, :custom_theme, :code, :client_url, :allow_sso, :allow_otp, :allow_otp_email, :allow_otp_mobile, :otp_code_expiration, :logo, :delete_logo, :sms_based,
    :client_customization_attributes, :is_locked, :ots_charges, :fixed_amount, :participant_rate, :opening_balance, :puc_rate, :is_fixed_amount, :is_participant_rate, :address, :is_live, :sms_number, :user_roles_main_attributes, :allow_total_points_deduction, :msp_id, :exotel_linked_number, :is_targeted_offer_enabled,
    :order_approval, :order_approval_limit


  attr_accessor :delete_logo

  serialize :settings, Hash

  has_attached_file :logo, :styles => {:medium => "180x80>"}, :default_url => "/assets/bvc-logo.png"

  has_paper_trail

  accepts_nested_attributes_for :user_roles_main, allow_destroy: true
  accepts_nested_attributes_for :client_customization, allow_destroy: true

  # Callbacks
  before_validation {logo.clear if delete_logo == "1"}
  before_save :append_client_key_and_secret
  before_create :create_client_catalog
  before_save :build_allow_otp
  after_save :update_msp

  has_attached_file :custom_theme
  validates_attachment :custom_theme, :content_type => {:content_type => ["text/css", "text/plain"]}
  validates :domain_name, :presence => true, :uniqueness => {:case_sensitive => false}, :if => lambda { |c| c.custom_theme.present? }
  validates :client_url, :presence => true, :if => lambda { |c| c.allow_sso? }
  validates :client_url, :format => {:with => /^(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?$/ix}, :if => lambda { |c| c.allow_sso? && c.client_url.present? }
  validate :validate_allow_otp
  validates :otp_code_expiration, :presence => true, :numericality => true, :if => lambda { |c| c.allow_otp? }
  validates :address, :presence => true, :length => {:minimum => 6 }
  validates :sms_number, :presence => true, :uniqueness => true, :format => {:with => /^\d*$/, :allow_blank => true}, :length => {:is => 10, :allow_blank => true}, :if => lambda { |c| c.sms_based? }
  validates :exotel_linked_number, :presence => true, :uniqueness => true, :format => {:with => /^\d*$/, :allow_blank => true}, :length => {:is => 10, :allow_blank => true}, :if => lambda { |c| c.sms_based? }

  SETTING_TYPES = ['custom_reset_password_url', 'saal_sms_based', 'saal_csv_upload']

  def after_initialize
    self.settings ||= {} 
  end

  Client::SETTING_TYPES.each do |type|
    define_method "#{type}?" do
      self.settings[type] && self.settings[type].to_bool || false
    end
  end

  def add_to_catalog(item_ids)
    item_ids.each do |item_id|
      client_item = client_items.find_by_item_id(item_id)
      if client_item.present? && client_item.deleted?
        client_item.update_attributes(:deleted => false, :margin => nil, :client_price => nil)
      else
        ClientItem.create!(:client_catalog_id => client_catalog.id, :item_id => item_id, :deleted => false)
      end
    end
  end

  def client_items
    client_catalog.client_items
  end

  def self.authenticate(client_key, client_secret)
    where(["client_key = ? AND client_secret = ?", client_key, client_secret]).first
  end

  def self.generate_invoices(date)
    find_each do |client|
      params = {invoice_type: ClientInvoice::InvoiceType::MONTHLY_RETAINER, invoice_date: date}
      client.client_invoices.create(params) unless client.client_invoices.exists?(params)
    end
  end

  def self.generate_statements(date)
    find_each do |client|
      params = {trans_date: date}
      client.client_point_reports.create(params) unless client.client_point_reports.exists?(params)
    end
  end

  def self.low_balance_reminder
    find_each do |client|
      ClientNotifier.notify(client)
    end
  end

  def average_points
    order_items = OrderItem.select(:points_claimed).where('scheme_id IN(?) AND DATE(created_at) > ?', schemes.pluck(:id), 5.days.ago).valid_orders.group('DATE(created_at)') if schemes.present?
    points = 0
    if order_items.present?
      points_claimed = order_items.map(&:points_claimed)
      points = (points_claimed.sum.to_f/points_claimed.length).round.to_i
    end
    points
  end

  def closing_balance
    client_point_reports.present? ? client_point_reports.last.balance : opening_balance
  end

  def data_hash
    {'data-points-ratio' => points_to_rupee_ratio.round || 0, 'data-puc-rate' => puc_rate || 0, 'data-service-tax' => SERVICE_TAX || 0}
  end

  def one_user_role?
    user_roles.size == 1
  end

  def one_scheme?
    schemes.size == 1
  end

  def msp_name
    (msp) ? msp.name : "-"
  end

  def option_format
    [client_name, id, {'data-parent' => msp_id}]
  end

  private

  def append_client_key_and_secret
    return nil if self.allow_sso == false || (self.client_key.present? && self.client_secret.present?)
    [:client_key, :client_secret].each do |column|
      begin
        self[column] = SecureRandom.hex((column == :client_key) ? CLIENT_KEY_LENGTH : nil)
      end while Client.exists?(column => self[column])
    end
  end

  def build_allow_otp
    self.allow_otp_email, self.allow_otp_mobile, self.otp_code_expiration = nil, nil, nil if self.allow_otp == false
  end

  def validate_allow_otp
    errors.add(:allow_otp) if allow_otp && (allow_otp_email == false && allow_otp_mobile == false)
  end

  def update_msp
    previous_msp_id = self.msp_id_was
    current_msp_id = self.msp_id
    if (self.msp_id_was.present? && self.msp_id.present?) && previous_msp_id != current_msp_id
      Supplier.where(msp_id: previous_msp_id).update_all(msp_id: current_msp_id)
      Category.where(msp_id: previous_msp_id).update_all(msp_id: current_msp_id)
    end
  end

end
