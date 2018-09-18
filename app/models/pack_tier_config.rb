class PackTierConfig < ActiveRecord::Base
  
  attr_accessible :codes, :reward_item_point_id, :tier_name, :user_role_id

  # Associations
  belongs_to :reward_item_point
  belongs_to :user_role
  has_many :unique_item_codes

  # Validations
  validates :reward_item_point, :user_role, :codes, :tier_name, :presence => true


end
