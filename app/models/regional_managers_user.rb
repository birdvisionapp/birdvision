class RegionalManagersUser < ActiveRecord::Base

  attr_accessible :regional_manager_id, :user_id

  # Associations
  belongs_to :regional_manager
  belongs_to :user

  # Scopes
  scope :by_resource, lambda {|user_id, regional_manager_id| where("regional_managers_users.user_id = ? AND regional_managers_users.regional_manager_id = ?",  user_id, regional_manager_id) }

end
