class LanguageTemplate < ActiveRecord::Base
  
  attr_accessible :name, :template, :status

  serialize :template, Hash

  # Validations
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}

  TEMPLATE_FIELDS = [:coupon_code]

  # Scopes
  [:active, :inactive].each do |status|
    scope status, where(status: status)
  end

  # Status
  module Status
    ACTIVE = 'active'
    INACTIVE = 'inactive'
    ALL = [ACTIVE, INACTIVE]
  end

  def render_templates
    details = []
    if template.present?
      template.each do |k, v|
        details << "#{k.to_s.titleize}: #{v}" if v.present?
      end
    end
    details.present? ? details : ["-"]
  end
 
end
