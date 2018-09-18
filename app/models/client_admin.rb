class ClientAdmin < ActiveRecord::Base

  self.table_name = 'regional_managers'

  extend CSVImportable
  
  include Admin::ClientAdminUserHelper

  attr_accessible :client, :client_id, :admin_user_id, :email, :mobile_number, :region, :name, :admin_user_attributes, :type, :address, :pincode
  
  belongs_to :admin_user
  belongs_to :client
  has_and_belongs_to_many :telecom_circles, :join_table => 'regional_managers_telecom_circles', :foreign_key => 'regional_manager_id'  

  has_paper_trail

  # Scopes
  scope :available, where('admin_users.deleted = ?', false)
  scope :for_client, lambda {|client_id| where(:client_id => client_id)}

  validates :client, :name, :presence => true
  validates :name, :uniqueness => {:case_sensitive => false, :scope => [:type, :client_id]}
  validates :email, :presence => true, :format => {:with => Devise.email_regexp, :allow_blank => true}
  validates :mobile_number, :presence => true,
    :numericality => {:only_integer => true, :allow_blank => true},
    :length => {:is => 10, :allow_blank => true}
  validates :mobile_number, :uniqueness => {:scope => [:type, :client_id]}

  before_save :sync_admin
  after_create :create_admin_user, :send_creation_email
  before_destroy :clear_links

  accepts_nested_attributes_for :admin_user

  def self.create_many_from_csv(csv_file, client_id, opts = {})
    self.import_from_file(csv_file, CsvClientAdmin.new(client_id, opts[:resource]))
  end

  def clear_links
    param = {regional_manager_id: id}
    RegionalManagersTelecomCircle.where(param).delete_all if type == 'RegionalManager'
    RegionalManagersUser.where(param).delete_all if type == 'Representative'
  end

end
