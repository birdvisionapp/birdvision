class AdminUser < ActiveRecord::Base
  module Roles
    SUPER_ADMIN = 'super_admin'
    RESELLER = 'reseller'
    CLIENT_MANAGER = 'client_manager'
    REGIONAL_MANAGER = 'regional_manager'
    REPRESENTATIVE = 'representative'
    ALL = [SUPER_ADMIN, RESELLER, CLIENT_MANAGER, REGIONAL_MANAGER, REPRESENTATIVE]
  end

  CLIENT_ADMINS = [Roles::CLIENT_MANAGER, Roles::REGIONAL_MANAGER, Roles::REPRESENTATIVE]

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :role, :reset_password_sent_at, :reset_password_token, :is_locked, :current_password, :deleted, :manage_roles, :msp_id

  #attr_protected :manage_roles

  attr_accessor :current_password

  has_one :reseller
  has_one :client_manager
  has_many :download_reports
  has_many :async_jobs
  has_one :regional_manager, :dependent => :destroy
  has_one :representative, :dependent => :destroy
  belongs_to :msp

  devise :database_authenticatable, :recoverable, :trackable
  has_paper_trail

  # Scopes
  scope :super_admins, lambda { |except_admin| where("admin_users.id <> ? AND admin_users.role = ? ", except_admin, AdminUser::Roles::SUPER_ADMIN) }
  scope :available, where(deleted: false)
  scope :site_super_admins, where('role IN(?) AND msp_id IS NULL', [AdminUser::Roles::SUPER_ADMIN, AdminUser::Roles::RESELLER])
  scope :non_msp_users, lambda {|is_super_dmin| where("admin_users.msp_id IS NULL") if is_super_dmin }

  validates :username, :presence => true, :length => {:within => 5..32, :allow_blank => true}, :format => {:with => /\A[a-zA-Z0-9._-]+\Z/}
  validates :username, :uniqueness => {:scope => [:msp_id, :deleted]}
  validates :email, :presence => true
  validates :email, :format => {:with => lambda { |a| (a.role == AdminUser::Roles::SUPER_ADMIN && !a.msp_id.present?) ? /\A([^@\s]+)@(birdvision\.in)\z/ : Devise.email_regexp}, :allow_blank => true}
  validates :password, :confirmation => {:if => :password_required?}, :presence => {:if => :password_required?},
    :length => {:within => 6..30, :allow_blank => true}

  after_create :send_activation_link, :if => Proc.new { self.role == AdminUser::Roles::SUPER_ADMIN }
  before_save :send_confirmation_email, :if => :encrypted_password_changed?
  after_save :send_change_password_email, :if => :encrypted_password_changed?
  before_create :build_msp_username
  before_save :set_msp_super_admin
  
  AdminUser::Roles::ALL.each do |role|
    define_method "#{role}?" do
      self.role == role
    end
  end

  def active_for_authentication?
    super and is_locked == false && deleted == false
  end

  def inactive_message
    (is_locked == true) ? :locked : :invalid
  end

  def soft_delete
    update_attribute(:deleted, true)
  end

  def manage_participants?
    if  role == "regional_manager"
      if RegionalManager.where(:admin_user_id => id).first.client_id == ENV['AL_CLIENT_ID'].to_i
        return true
      end
    end
    (role == AdminUser::Roles::SUPER_ADMIN || role == AdminUser::Roles::CLIENT_MANAGER)
  end

  private

  def password_required?
    !password.blank? || !password_confirmation.blank?
  end

  def send_activation_link
    update_attributes!(:reset_password_token => AdminUser.reset_password_token, :reset_password_sent_at => DateTime.current)
    SuperAdminUserMailer.delay.send_account_activation_link(self)
  end

  def send_confirmation_email
    unless new_record?
      SuperAdminUserMailer.delay.send_account_confirmation(self) if encrypted_password_was.empty?
    end
  end

  def send_change_password_email
    unless new_record?
      SuperAdminUserMailer.delay.send_change_password_confirmation(self, self.password)
    end
  end

  def build_msp_username
    if role == AdminUser::Roles::SUPER_ADMIN && msp_id.present? && username_changed?
      msp_label = msp.user_label
      uname = (username[msp_label]) ? username.split(msp_label)[1] : username
      self.username = "#{msp_label}#{uname}"
      self.manage_roles = true unless msp.admin_users.size > 0
    end
  end

  def set_msp_super_admin
    if role == AdminUser::Roles::SUPER_ADMIN && msp_id.present? && manage_roles_changed?
      msp.admin_users.where("admin_users.id != ?", id).update_all(manage_roles: false)
    end
  end

end
