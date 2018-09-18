class TargetedOfferValidity < ActiveRecord::Base
  attr_accessible :end_date, :start_date
  belongs_to :targeted_offer_config
end
