class ClientManager < ActiveRecord::Base
  include Admin::ClientAdminUserHelper

  attr_accessible :client, :client_id, :admin_user, :name, :mobile_number, :email, :admin_user_attributes, :is_client_dashboard_unabled
  belongs_to :admin_user
  belongs_to :client

  has_paper_trail
  has_one :threshold
  has_many :widgets, through: :client_managers_widgets
  
  # Scopes
  scope :available, where('admin_users.deleted = ?', false)

  validates :client, :name, :presence => true
  validates :email, :presence => true, :format => {:with => Devise.email_regexp, :allow_blank => true}
  validates :mobile_number, :presence => true,
            :numericality => {:only_integer => true, :allow_blank => true},
            :length => {:is => 10, :allow_blank => true}

  before_save :sync_admin
  after_create :create_admin_user, :send_creation_email

  accepts_nested_attributes_for :admin_user

  def self.associated_client_for admin_user
    for_admin_user(admin_user).client
  end

  def self.for_admin_user admin_user
    where(:admin_user_id => admin_user.id).first
  end

  private
  def create_admin_user
    return if admin_user.present?
    username = "#{client.code}_cm.#{id}"
    user_params = {:username => username, :email => email, :role => AdminUser::Roles::CLIENT_MANAGER}
    user_params.merge!(:msp_id => client.msp_id) if client.msp_id.present?
    self.admin_user = AdminUser.create!(user_params)
    save!
  end

  def send_creation_email
    email_password_reset_instructions_to(self)
  end

  def sync_admin
    admin_user.update_attributes!(:email => self.email) if admin_user.present?
  end
end
