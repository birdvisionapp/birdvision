class Incentive < ActiveRecord::Base
  
  belongs_to :targeted_offer_config
  attr_accessible :incentive_name, :incentive_description, :incentive_type, :incentive_for, :incentive_detail, :targeted_offer_configs_id
end
