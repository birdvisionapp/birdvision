require 'spec_helper'

describe Admin::ClientAdminUserHelper do

  it "should send email to reseller for account activation" do
    admin_user = Fabricate(:admin_user, :password => nil, :reset_password_token => nil)

    client_admin_user = mock("reseller or client manager")
    client_admin_user.stub(:admin_user).and_return(admin_user)

    mailer = mock("client_admin_user_mailer")
    mailer.should_receive(:send_account_activation_link).exactly(1).times
    ClientAdminUserMailer.stub(:delay).and_return mailer

    email_password_reset_instructions_to client_admin_user

    admin_user.reset_password_token.should_not be_nil
  end
end