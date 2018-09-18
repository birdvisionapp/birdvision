require 'spec_helper'

describe SmsMessage do
  let(:sms) { SmsMessage.new(:account_registration, :to => "9876543210", :client => "some_client", :email => "abc@xyz.com") }
  let(:exotel_sms) { mock("exotel_sms") }
  let(:response) { mock("response") }
  it "should deliver messages" do
    Exotel::Sms.stub(:new).and_return(exotel_sms)
    ENV.should_receive(:[]).with("SMS_SENDER").and_return("LM-BVC")
    response.stub(:sid)
    exotel_sms.should_receive(:send).with(:from => "LM-BVC", :to => "9876543210", :body => "You are now a part of the some_client rewards program.Please check your registered email: abc@xyz.com for more details. - some_client Rewards Team").and_return(response)

    sms.deliver
  end

  it "should not deliver messages if SMS_SENDER env variable not present" do
    ENV.stub(:[]).with("SMS_SENDER").and_return(nil)
    exotel_sms.should_receive(:send).never

    sms.deliver
  end
end