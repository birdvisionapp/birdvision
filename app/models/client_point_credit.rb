class ClientPointCredit < ActiveRecord::Base
  
  attr_accessible :client_id, :points, :created_at

  # Associations
  belongs_to :client

  # Validations
  validates :client, :presence => true

end
