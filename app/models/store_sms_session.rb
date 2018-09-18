class StoreSmsSession < ActiveRecord::Base
  attr_accessible :sms_id, :from_user, :response
end
