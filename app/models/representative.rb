class Representative < ClientAdmin

  extend Admin::ClientAdminUserHelper
  
  attr_accessible :user_ids

  # Scopes
  scope :select_options, select([:id, :name, :client_id]).order(:client_id)
  

  #validates :user_ids, :presence => true

  # Associations
  has_and_belongs_to_many :users, :join_table => 'regional_managers_users', :foreign_key => 'regional_manager_id'


  def self.notify_daily_status
    includes(:admin_user).available.find_each do |client_admin|
      RepresentativeNotifier.notify_daily_status(client_admin)
    end
  end

end
