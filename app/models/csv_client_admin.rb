class CsvClientAdmin

  def initialize(client_id = nil, resource)
    @client_id = client_id
    @resource = resource
  end

  def headers
    common_headers = %w(name email mobile_number address pincode)
    common_headers.unshift('region') if @resource == 'regional_manager'
    common_headers
  end

  def from_hash(attr_hash)
    attr_hash.keep_if { |key, value| value.present? && headers.include?(key) }
    client_admin = Csv::ClientAdminBuilder.new(attr_hash, @resource).build
    client_admin.client_id = @client_id
    client_admin
  end

  def batch_from_hash(rows)
    rows.collect { |row| from_hash(row) }
  end

  def unique_attribute
    #"id"
  end

  def template
    headers.join(",")
  end

end
