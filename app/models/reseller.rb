class Reseller < ActiveRecord::Base
  include Admin::ClientAdminUserHelper
  include Admin::Reports::SalesReports

  attr_accessible :name, :phone_number, :email, :admin_user, :admin_user_attributes

  belongs_to :admin_user
  has_many :client_resellers

  has_paper_trail

  # Scopes
  scope :available, where('admin_users.deleted = ?', false)

  validates :name, :presence => true
  validates :email, :presence => true, :format => {:with => Devise.email_regexp, :allow_blank => true}
  validates :phone_number, :presence => true,
            :numericality => {:only_integer => true, :allow_blank => true},
            :length => {:is => 10, :allow_blank => true}

  after_create :create_admin_user

  accepts_nested_attributes_for :admin_user

  def assigned_client_resellers
    ClientReseller.where(:assigned => true, :reseller_id => self.id)
  end

  def create_admin_user
    return if admin_user.present?
    username = "bvc.#{id}"
    self.admin_user = AdminUser.create!(:username => username, :email => email, :role => AdminUser::Roles::RESELLER)
    save!
    email_password_reset_instructions_to(self)
  end

  def payout_total
    client_resellers.inject(0) { |total, client_reseller| total += client_reseller.payout }
  end

  def sales_total
    client_resellers.inject(0) { |total, client_reseller| total += client_reseller.sales }
  end

  def unassign client
    client_resellers.each { |client_reseller| client_reseller.update_attributes!(:assigned => false, :payout_end_date => Date.today) if client_reseller.client_id == client.id }
  end
end