class Msp < ActiveRecord::Base

  attr_accessible :address, :contact_name, :phone_number, :email, :fixed_amount, :name, :opening_balance, :setup_charge, :plan_details, :notes, :status,
                  :is_targeted_offer_enabled
  
  has_paper_trail

  # Status
  module Status
    ACTIVE = 'active'
    INACTIVE = 'inactive'
    ALL = [ACTIVE, INACTIVE]
  end

  # Associations
  has_many :admin_users
  has_many :clients
  has_many :categories
  has_many :suppliers
  has_many :targeted_offer_configs
  
  # Scopes
  #scope :available, where(deleted: false)
  scope :select_options, -> { select([:id, :name]) }
  
  # Validations
  validates :name, :contact_name, :phone_number, :email, :address, :fixed_amount, :opening_balance, :setup_charge, :plan_details, :notes, :presence => true
  validates :name, :uniqueness => {:case_sensitive => false}
  validates :email, :format => {:with => Devise.email_regexp}
  validates :phone_number, :fixed_amount, :opening_balance, :setup_charge, :numericality => true

  # Callbacks
  #after_create :create_super_admin

  def user_label
    "msp_#{id}."
  end

  private

  def create_super_admin
    self.admin_users.create!(:username => "#{user_label}admin", :email => email, :role => AdminUser::Roles::SUPER_ADMIN, :manage_roles => true)
  end

end
