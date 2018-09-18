Exotel.configure do |c|
  c.exotel_sid   = 'birdvision' #ENV["EXOTEL_SID"]
  c.exotel_token = 'affd29cb8460a4b0b0d4dee69ad3d8c15a078782' #ENV["EXOTEL_TOKEN"]
end

module Exotel

  class Response
    def set_response_data(response_base)
      (response_base['Call'] or response_base['SMSMessage'] or response_base['Numbers']).each do |key, value|
        set_variable(key, value)
      end
    end
  end
  
  def Sms.metadata(phone_number)
    sms = Exotel::Sms.new
    response = self.get("/#{Exotel.exotel_sid}/Numbers/#{phone_number}", :basic_auth => sms.__send__(:auth))
    sms.__send__(:handle_response, response)
  end

end