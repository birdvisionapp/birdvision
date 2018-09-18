class User < ActiveRecord::Base

  has_ancestry

  extend CSVImportable
  extend Admin::Reports::ParticipantReport

  has_paper_trail :ignore => [:last_sign_in_ip, :current_sign_in_ip, :last_sign_in_at, :current_sign_in_at, :sign_in_count, :updated_at]

  belongs_to :client
  has_many :orders
  has_many :user_schemes, :inverse_of => :user, :dependent => :destroy, :autosave => true
  has_many :access_grants, :dependent => :delete_all
  has_many :scheme_transactions
  has_many :unique_item_codes
  belongs_to :user_role
  belongs_to :telecom_circle
  has_many :product_code_links, :as => :linkable
  has_and_belongs_to_many :representatives, :join_table => 'regional_managers_users', :association_foreign_key => 'regional_manager_id'
  has_many :regional_managers_users, :foreign_key => 'user_id'
  has_many :to_transactions
  has_many :al_transactions
  # has_many :al_channel_linkages
  before_save :send_activation_success_email, :if => :encrypted_password_changed?
  
  attr_accessor :registration_type, :coupen_code, :schemes

  attr_accessible :participant_id, :full_name, :username, :email, :mobile_number, :landline_number, :registration_type,
    :schemes, :address, :pincode, :notes, :sign_in_count, :extra_options, :user_role_id, :telecom_circle_id,
    :password, :password_confirmation, :reset_password_sent_at, :reset_password_token, :client, :activation_status, :status, :ancestry, :parent_id,
    :anniversary, :dob, :coupen_code, :client_id, :slogan, :avatar, :extra_pic, :extra_field

  has_attached_file :avatar, :default_url => "/assets/no_image_available.png"
  validates_attachment :avatar, size: { in: 0..1024.kilobytes }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/, :message => :invalid_avatar
  
  has_attached_file :extra_pic, :default_url => "/assets/no_image_available.png"
  validates_attachment :extra_pic, size: { in: 0..1024.kilobytes }
  validates_attachment_content_type :extra_pic, content_type: /\Aimage\/.*\Z/, :message => :invalid_extra_pic
  
  devise :database_authenticatable, :recoverable, :trackable

  validates :user_role, :presence => true, :if => :persisted?
  validates :participant_id, :presence => true, :format => {:with => /^\S*$/}
  validates :full_name, :presence => true
  validates :email, :format => {:with => Devise.email_regexp, :allow_blank => true}
  validates :mobile_number, :presence => true, :format => {:with => /^\d*$/, :allow_blank => true}, :length => {:is => 10, :allow_blank => true}
  validates :username, :uniqueness => true
  validates :client, :presence => true
  validates :password, :confirmation => {:if => :password_required?}, :presence => {:if => :password_required?},
    :length => {:within => 6..30, :allow_blank => true}
  #validates :parent_id, :presence => true, :if => :persisted?

  before_create :generate_user_name
  before_create :set_default_activation_status
  after_save :send_sms_registration_confirmation
  after_save :fetch_telecom_circle
  after_create :send_activation_email
  after_create :send_new_registration_details
  after_create :hal_send_registration_sms
  
  has_one_time_password


  module ActivationStatus
    LINK_NOT_SENT = 'Link Not Sent'
    NOT_ACTIVATED = 'Not Activated'
    ACTIVATED = 'Activated'
    ALL = [LINK_NOT_SENT, NOT_ACTIVATED, ACTIVATED]
  end

  module Status
    PENDING = 'pending'
    ACTIVE = 'active'
    INACTIVE = 'inactive'
    ALL = [PENDING, ACTIVE, INACTIVE]
  end

  RETAILER_SLUG = 'retailer'

  scope :for_client, lambda { |client| includes(:user_schemes => {:scheme => :client}).where("clients.id" => client) }
  scope :sms_based, where('clients.sms_based = ?', true)
  [:pending, :active, :inactive].each do |status|
    scope status, where(status: status)
  end
  scope :for_mobile_number, lambda {|mobile_number| where(:mobile_number => mobile_number) }
  scope :is_retailer, -> {includes(:user_role).where('lower(user_roles.name) = ?', RETAILER_SLUG)}
  scope :is_not_retailer, -> {where('ancestry IS NOT NULL')}
  scope :for_participant_id, lambda {|participant_id| where('lower(participant_id) = ?', participant_id.downcase) if participant_id.present? }
  scope :region_scope, where('users.client_id = regional_managers.client_id')
  scope :exclude_linked, lambda {|user_ids| where('users.id NOT IN(?)', user_ids) if user_ids.present? }
  scope :no_links, -> {includes(:representatives).where(regional_managers_users: { user_id: nil })}

  def generate_user_name
    self.username = "#{self.client.code.parameterize}.#{self.participant_id}".downcase
  end

  def set_default_activation_status
    self.status.downcase! if self.status.present?
    return nil if self.status.downcase == Status::ACTIVE || self.client.allow_sso? || self.client.sms_based?
    self.activation_status = ActivationStatus::LINK_NOT_SENT unless self.activation_status.present?
  end

  def client_name
    self.client.client_name if self.client.present?
  end

  def send_new_registration_details
   unless new_record?
      if self.email?
        UserNotifier.notify_participant_registration(self)
      end
    end
  end

  def total_redeemable_points
    total_points_for_past_and_active_schemes - total_redeemed_points
  end

  def self.create_many_from_csv(csv_file, scheme_id, opts = {})
    scheme = Scheme.find(scheme_id)
    self.import_from_file(csv_file, CsvUser.new(scheme, opts[:add_points], opts[:category]))
  end

  def total_redeemed_points
    user_schemes.clubbable.sum("redeemed_points")
  end

  def total_points_for_past_and_active_schemes
    user_schemes.clubbable.merge(Scheme.redeemable_or_expired).sum("total_points")
  end

  def schemes
    Scheme.joins(:user_schemes).where("user_schemes.user_id = ? ", self)
  end

  def self.generate_activation_token_for user_id
    attributes = {:reset_password_token => User.reset_password_token, :reset_password_sent_at => DateTime.current}
    attributes.merge!(:activation_status => User::ActivationStatus::NOT_ACTIVATED) if User.find(user_id).activation_status != User::ActivationStatus::ACTIVATED
    User.update(user_id, attributes)
  end

  def send_one_time_password
    begin
      self.otp_secret_key = ROTP::Base32.random_base32
    end while self.class.exists?(otp_secret_key: otp_secret_key)
    self.save
    UserNotifier.notify_one_time_password(self)
  end

  def send_one_time_password_sms balance
    begin
      balance = balance
      self.otp_secret_key = ROTP::Base32.random_base32
    end while self.class.exists?(otp_secret_key: otp_secret_key)
    self.save
    return self
  end

  def check_one_time_password(otp)
    return nil unless self.otp_secret_key.present?
    begin
      otp_auth = self.authenticate_otp(otp, :drift => self.client.otp_code_expiration)
      self.update_attribute(:otp_secret_key, nil) if otp_auth
    rescue

    end
  end

  def self.build_username_with_participant(client_code, participant_id)
    "#{client_code.parameterize}.#{participant_id}".downcase
  end

  def active_for_authentication?
    super and status.downcase == Status::ACTIVE && !client.is_locked?
  end

  def inactive_message
    I18n.translate((client.is_locked?) ? 'devise.failure.contact_client' : 'devise.failure.inactive', :client_name => client.client_name)
  end

  def self.build_user_scheme(user, unique_item_codes)
    puts "***********************build_user_scheme******************************"
    puts user.inspect
    puts unique_item_codes.inspect
    UserScheme.skip_callback("save", :after, :send_notification)
    unique_item_codes.each {|unique_item_code| self.update_points_for(user, unique_item_code) }
    UserScheme.set_callback("save", :after, :send_notification)
  end

  def self.update_points_for(user, unique_item_code)
    scheme = unique_item_code.reward_item_point.reward_item.scheme
    user_scheme = user.user_schemes.where(:scheme_id => scheme.id).first
    reward_points = unique_item_code.reward_item_point.points
    to_user_check = check_to_for_user(user)
    unless to_user_check.nil?
      extra_points = apply_to_configuration(to_user_check, user, reward_points, unique_item_code)
      points = reward_points + extra_points
    else
      points = reward_points
    end
    if user_scheme.present?
      user_scheme.update_attribute(:total_points, (user_scheme.total_points + points).to_i)
      puts "********************update_points_for-----user_scheme.present?*************************"
      puts user_scheme.inspect
    else
      attrs = {:scheme_id => scheme.id, :total_points => points}
      attrs.merge!(:level => scheme.level_clubs.first.level, :club => scheme.level_clubs.first.club)
      user_scheme = user.user_schemes.create!(attrs)
      puts "********************update_points_for---user_scheme.present-else*************************"
      puts user_scheme.inspect
    end
    user_scheme
  end

  def self.notify_retailer_balance
    is_retailer.find_each do |user|
      UserNotifier.notify_balance(user)
    end
  end

  def is_retailer?
    user_role && user_role.name.downcase == RETAILER_SLUG
  end

  def name_mobile
    "#{full_name} - #{mobile_number}"
  end

  def children_details
    '' unless children.present?
    children.map{|user|
      user.name_mobile
    }.join(", ").html_safe
  end

  def role_display
    user_role ? user_role.display_name : '-'
  end

  def assign_telecom_circle
    meta_data = Exotel::Sms.metadata(self.mobile_number)
    if meta_data.present? && meta_data.circle.present?
      circle = TelecomCircle.select(:id).for_code(meta_data.circle).first
      self.update_column(:telecom_circle_id, circle.id) if circle.present?
    end
  end

  def region
    return '' unless telecom_circle.present?
    managers = telecom_circle.regional_managers.map{|r|{client_id: r.client_id, region: r.region}}
    if managers.present?
      region = managers.find_all{|v| v[:client_id] == client_id}
      if region.present?
        region[0][:region]
      end
    end
  end

  def circle_name
    telecom_circle.name rescue 'Undefined'
  end

  def sms_status
    (status.downcase == User::Status::ACTIVE) ? 'Registered' : status.titleize
  end

  private

  def password_required?
    !password.nil? || !password_confirmation.nil?
  end

  def send_activation_success_email
    unless new_record?
      self.activation_status = ActivationStatus::ACTIVATED
      self.status = Status::ACTIVE
      self.activated_at = Time.now
      UserNotifier.notify_activation_complete(self)
    end
  end

  def  hal_send_registration_sms
    if self.client_id == 421
      puts "==============HAL SMS================="
      UserNotifier.notify_sms_based_registration_hal(self)
      UserScheme.skip_callback("save", :after, :send_notification)
    end
  end
  
  def send_sms_registration_confirmation
    unless new_record?
      if self.client.sms_based? && self.status_was == User::Status::PENDING && self.status.downcase == User::Status::ACTIVE
        User.build_user_scheme(self, self.unique_item_codes.select([:id, :reward_item_point_id])) if self.unique_item_codes.present?
        UserNotifier.notify_sms_based_registration(self)
      end
    end
  end

  def fetch_telecom_circle
    self.delay.assign_telecom_circle if self.mobile_number.present? && (!self.telecom_circle_id.present? || self.mobile_number_was != self.mobile_number)
  end

  def send_activation_email
    if ((self.registration_type == :send_activation_email) || (self.registration_type == :csv_upload && self.client.saal_csv_upload?) || (self.registration_type == :sms && self.client.saal_sms_based? && self.client.sms_based?))
      user = User.generate_activation_token_for self.id
      UserNotifier.notify_activation(user)
    end
  end
  
  def self.check_to_for_user(user)
    #search_user = ToApplicableUser.where(:user_id => user.id)
    search_user = ToApplicableUser.where(:user_id => user.id).where('used_at IS NULL')
    unless search_user.empty?
      search_user
    else
      nil
    end 
  end
  
  def self.apply_to_configuration(to_applicable, user, reward_points, unique_item_code)
    validity = to_applicable.first.targeted_offer_config.targeted_offer_validity
    applicable_products = to_applicable.first.targeted_offer_config.to_products
    unique_code = unique_item_code.code
    if validity.end_date > Date.today
      prodcut_id = UniqueItemCode.joins(reward_item_point: :reward_item).select("reward_items.id").where(unique_item_codes: {id: unique_item_code.id})
      if applicable_products.include?(prodcut_id.first.id.to_s)
        incentive = Incentive.where(:targeted_offer_configs_id => to_applicable.first.targeted_offer_config_id).first
        if incentive.incentive_type == "percentage"
          extra_points = reward_points * incentive.incentive_detail.to_i * 0.01
          store_to_transaction_info(user, to_applicable.first, incentive, extra_points, "percentage", prodcut_id, unique_code)
        elsif incentive.incentive_type == "catlog-gift"
          extra_points = 0
          store_to_transaction_info(user, to_applicable.first, incentive, extra_points, "catlog-gift", prodcut_id, unique_code)
        elsif incentive.incentive_type == "client-gift"
          extra_points = 0
          store_to_transaction_info(user, to_applicable.first, incentive, extra_points, "client-gift", prodcut_id, unique_code)
        else
          extra_points = 0
        end
      else
        extra_points = 0
      end
    else
      extra_points = 0
    end
    extra_points
  end
  
  def self.store_to_transaction_info(user, to_applicable, incentive, extra_points, incentive_type, prodcut_id, unique_code)
    participant_id = User.find(user.id).participant_id
    targeted_offer_basis = to_applicable.targeted_offer_config.template.targeted_offer_type.id

    if incentive_type == "percentage"
      transaction = ToTransaction.new(:user_id => user.id, :participant_id => participant_id, :targeted_offer_basis => targeted_offer_basis, :incentive_type => "Auto Fullfillment", :to_applicable_user_id => to_applicable.id, :targeted_offer_config_id => to_applicable.targeted_offer_config_id, :incentive_id => incentive.id, :extra_points => extra_points, :status => "delivered" ,:delivered_at => DateTime.now, :unique_code => unique_code)
      incentive_detail_point = incentive.incentive_detail.to_i
      UserNotifier.notify_extra_point_updated(user, incentive_detail_point, prodcut_id)
    else
      transaction = ToTransaction.new(:user_id => user.id, :participant_id => participant_id, :targeted_offer_basis => targeted_offer_basis, :incentive_type => "Manual", :to_applicable_user_id => to_applicable.id, :targeted_offer_config_id => to_applicable.targeted_offer_config_id, :incentive_id => incentive.id, :unique_code => unique_code)
    end
      transaction.save!
      update_to_applicable_user(to_applicable, incentive)
  end

  def self.update_to_applicable_user(to_applicable, incentive)
    if incentive.incentive_for == "first_action"
      update_user = to_applicable.update_attributes(:used_at => DateTime.now)
    end
  end

  def self.update_user_scheme(user, user_transaction)
    UserScheme.skip_callback("save", :after, :send_notification)
    self.update_user_scheme_for(user, user_transaction)
    UserScheme.set_callback("save", :after, :send_notification)
  end

  def self.update_user_scheme_for(user, user_transaction)
    scheme = user_transaction.reward_item_point.reward_item.scheme
    user_scheme = user.user_schemes.where(:scheme_id => scheme.id).first
    if user_scheme.present?
      user_scheme.update_attribute(:total_points, (user_scheme.total_points + user_transaction.total_points).to_i)
    end
    user_scheme
  end

end