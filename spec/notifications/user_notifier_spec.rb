require 'spec_helper'

describe UserNotifier do

  let(:mailer) { mock('mailer') }

  it "should send activation email, sms" do
    user = Fabricate(:user)
    UserMailer.should_receive(:delay).and_return(mailer)
    mailer.should_receive(:send_account_activation_link).with(user)

    msg = mock("message")
    msg.stub_chain(:delay, :deliver)
    SmsMessage.should_receive(:new).with(:account_registration, :to => user.mobile_number, :client => user.client.client_name, :email => user.email).and_return(msg)

    UserNotifier.notify_activation(user)
  end

  it "should send activation complete sms, email" do
    user = Fabricate(:user, :password => nil, :client => Fabricate(:client, :domain_name => 'acme.inc'))
    UserMailer.should_receive(:delay).and_return(mailer)
    mailer.should_receive(:account_activation).with(user)

    msg = mock("message")
    msg.stub_chain(:delay, :deliver)
    SmsMessage.should_receive(:new).with(:account_activation, :to => user.mobile_number, :username => user.username, :domain => 'acme.inc', :client => user.client.client_name).and_return(msg)

    UserNotifier.notify_activation_complete(user)
  end

  it "should send activation sms with default host if no domain_name is set for client" do
    user = Fabricate(:user, :password => nil, :client => Fabricate(:client, :domain_name => ''))
    UserMailer.should_receive(:delay).and_return(mailer)
    mailer.should_receive(:account_activation).with(user)

    msg = mock("message")
    msg.stub_chain(:delay, :deliver)
    SmsMessage.should_receive(:new).with(:account_activation, :to => user.mobile_number, :username => user.username, :domain => 'localhost', :client => user.client.client_name).and_return(msg)

    UserNotifier.notify_activation_complete(user)
  end

  it "should send one time password by sms and email" do
    user = Fabricate(:user, :client => Fabricate(:client_allow_otp))
    otp_code = user.otp_code
    UserMailer.should_receive(:delay).and_return(mailer)
    mailer.should_receive(:send_one_time_password).with(user, otp_code)

    msg = mock("message")
    msg.stub_chain(:delay, :deliver)
    SmsMessage.should_receive(:new).with(:one_time_password, :to => user.mobile_number, :username => user.username, :otp_code => otp_code, :client => user.client.client_name).and_return(msg)

    UserNotifier.notify_one_time_password(user)
  end

  it "should send one time password by sms only" do
    user = Fabricate(:user, :client => Fabricate(:client_allow_otp, :allow_otp_email => false))
    otp_code = user.otp_code
    mailer.should_not_receive(:send_one_time_password).with(user, otp_code)

    msg = mock("message")
    msg.stub_chain(:delay, :deliver)
    SmsMessage.should_receive(:new).with(:one_time_password, :to => user.mobile_number, :username => user.username, :otp_code => otp_code, :client => user.client.client_name).and_return(msg)

    UserNotifier.notify_one_time_password(user)
  end

  it "should send one time password by email only" do
    user = Fabricate(:user, :client => Fabricate(:client_allow_otp, :allow_otp_mobile => false, :allow_otp_email => true))
    otp_code = user.otp_code
    UserMailer.should_receive(:delay).and_return(mailer)
    mailer.should_receive(:send_one_time_password).with(user, otp_code)

    msg = mock("message")
    msg.stub_chain(:delay, :deliver)
    SmsMessage.should_not_receive(:new).with(:one_time_password, :to => user.mobile_number, :username => user.username, :otp_code => otp_code, :client => user.client.client_name).and_return(msg)

    UserNotifier.notify_one_time_password(user)
  end
end