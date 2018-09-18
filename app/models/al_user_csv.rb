class AlUserCsv
  
  def initialize(admin_user)
    @admin = admin_user
  end
  
  def headers
    ['Date', 'Sales Office Code', 'Sales Group Code',  'SAP Code',  'Dealer Hierarchy',  'Part Number', 'Quantity']
  end
  
  def template
    headers.join(",")
  end
  
end