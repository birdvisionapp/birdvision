class ToUtilizer < ActiveRecord::Base
  attr_accessible :to_applicable_user_id, :status , :result, :targeted_offer_config_id
  belongs_to :to_applicable_user
  belongs_to :targeted_offer_config
end
