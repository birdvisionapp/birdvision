class RegionalManager < ClientAdmin

  extend Admin::ClientAdminUserHelper
  
  attr_accessible :telecom_circle_ids
  
  has_many :al_channel_linkages
  
  # Scopes
  scope :select_options, select([:id, :region, :client_id]).order(:client_id)

  validates :region, :telecom_circle_ids, :presence => true
  validates :region, :uniqueness => {:case_sensitive => false, :scope => :client_id}

  def region_with_client
    "#{client.client_name} > #{region}"
  end
  
end
