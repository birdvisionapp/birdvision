class TargetedOfferType < ActiveRecord::Base
  attr_accessible :offer_type_name, :description
  has_many :templates
end
