class ToApplicableUser < ActiveRecord::Base
  attr_accessible :targeted_offer_config_id, :user_id, :user_purchase_frequency, :to_availed, :used_at
  belongs_to :targeted_offer_config
  has_one :to_utilizers
end
