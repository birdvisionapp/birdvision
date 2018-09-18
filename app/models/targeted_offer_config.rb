class TargetedOfferConfig < ActiveRecord::Base

  belongs_to :client
  belongs_to :msp
  
  has_one :incentive
  has_one :targeted_offer_validity
  
  belongs_to :template
  has_many :to_applicable_users
  has_many :to_utilizers
  
  belongs_to :targeted_offer_type
  
  attr_accessible :targeted_offer_validity_id,
                  :name, :sms_based , :email_based , :template_id ,
                  :start_age , :end_age , :client_purchase_frequency,
                  :to_schemes, :to_user_roles, :to_products, :to_telephone_circles ,
                  :client_id , :msp_id , :status , :performance_from , :performance_to ,
                  :festival_type, :to_disabled
                   
  serialize :to_schemes 
  serialize :to_user_roles
  serialize :to_products
  serialize :to_telephone_circles
end