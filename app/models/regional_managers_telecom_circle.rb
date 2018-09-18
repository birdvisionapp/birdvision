class RegionalManagersTelecomCircle < ActiveRecord::Base

  # Associations
  belongs_to :regional_manager
  belongs_to :telecom_circle

end
