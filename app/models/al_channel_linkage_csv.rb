class AlChannelLinkageCsv
  
  def initialize(admin_user)
    @admin = admin_user
  end
  
  def headers
    ['retailer_code', 'ro_code', 'dealer_codes']
  end
  
  def template
    headers.join(",")
  end
  
  def unique_attribute
    "retailer_code"
  end
  
end