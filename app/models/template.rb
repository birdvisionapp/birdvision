class Template < ActiveRecord::Base

  belongs_to :targeted_offer_type
  has_one :targeted_offer_config
  has_many :clients_templates
  has_many :clients, :through=>:clients_templates

  attr_accessible :template_content, :name, :targeted_offer_type_id

  validates :name, presence: true
  validates :template_content, presence: true
  validates :targeted_offer_type,  presence: true
end
