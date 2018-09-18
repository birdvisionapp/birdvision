module Csv
  class UserBuilder
    def initialize(client, existing_user, attrs)
      @client = client
      @existing_user =existing_user
      @attrs = attrs
    end

    def build
      user = @existing_user
      attrs = @attrs.slice(*[:participant_id, :full_name, :username, :email, :mobile_number, :landline_number,
                             :schemes, :address, :pincode, :notes, :activation_status, :status].collect(&:to_s))
      return User.new(attrs.merge(:client => @client)) if user.nil?
      user.assign_attributes(attrs)
      user
    end
  end
end
