module Csv
  class ClientAdminBuilder
    def initialize(attrs, resource)
      @resource = resource
      @attrs = attrs
    end

    def build
      attrs = @attrs.slice(*[:name, :email, :mobile_number, :address, :pincode].collect(&:to_s))
      client_admin = ClientAdmin.new
      attrs.merge!(@attrs.slice(*[:region].collect(&:to_s))) if @resource == 'regional_manager'
      attrs.merge!(type: @resource.classify)
      client_admin.assign_attributes(attrs)
      client_admin
    end
  end
end
