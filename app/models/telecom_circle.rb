class TelecomCircle < ActiveRecord::Base
  
  attr_accessible :code, :description

  # Associations
  has_and_belongs_to_many :regional_managers, :uniq => true
  
  # Validations
  validates :code, :description, :presence => true
  validates :code, :uniqueness => {:case_sensitive => false}

  # Scopes
  scope :for_code, lambda {|code| where('lower(code) = ?', code.downcase) if code.present? }

  def name
    description.split("(")[0].strip
  end

end
