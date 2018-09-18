require "spec_helper"

describe UserMailer do
  context 'mail' do

    it 'should send email with account activation link' do
      user = Fabricate(:user, :email => 'user@me.com')
      UserMailer.any_instance.should_receive(:sendgrid_category).with('Participant Account Activation')
      UserMailer.any_instance.should_receive(:sendgrid_unique_args).with(:participant_id => user.participant_id)

      mail = UserMailer.send_account_activation_link(user)

      mail.should deliver_to(user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{user.client.client_name} Rewards Program - Account Activation Details")

      mail.should have_body_text("Dear #{user.full_name}")
      mail.should have_body_text("We are pleased to inform you that")
      mail.should have_body_text("Your user name is:")
      mail.should have_body_text("#{user.username}")
      mail.should have_body_text(root_url+"users/password/edit?mode=activate")

      mail.should have_body_text("Please save your username for all future reference and communication.")
      mail.should have_link("Contact Us", :href => "http://localhost/contact_us")

    end

    it 'should send email for account activation' do
      user = Fabricate(:user, :email => 'user@me.com')
      user.password = "new password"
      user.save

      UserMailer.any_instance.should_receive(:sendgrid_category).with('Participant Account Confirmation')
      UserMailer.any_instance.should_receive(:sendgrid_unique_args).with(:participant_id => user.participant_id)

      mail = UserMailer.account_activation(user)

      mail.should deliver_to(user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{user.client.client_name} Rewards Program - Account Details")

      mail.should have_body_text("Dear #{user.full_name}")
      mail.should have_body_text("Your account details are as follows:")
      mail.should have_body_text("Username for login:")
      mail.should have_body_text("#{user.username}")
      mail.should have_body_text("#{user.participant_id}")
      mail.should have_body_text("#{user.client.client_name}")
      user.schemes.each do |scheme|
        mail.should have_body_text("#{scheme.name}")
      end

      mail.should have_body_text("You can sign in to your account by clicking the following link:")
      mail.should have_link("Contact Us", :href => "http://localhost/contact_us")

    end

    it 'should send email for account update' do
      user = Fabricate(:user, :email => 'user@me.com')

      UserMailer.any_instance.should_receive(:sendgrid_category).with('Participant Account Update')
      UserMailer.any_instance.should_receive(:sendgrid_unique_args).with(:scheme => "scheme_name", :participant_id => user.participant_id)

      mail = UserMailer.account_update(user, "scheme_name", {:total_points => 1200})

      mail.should deliver_to(user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{user.client.client_name} Rewards Program - Account Update Notification")

      mail.should have_body_text("Dear #{user.full_name}")
      mail.should have_body_text("Your '<strong>scheme_name</strong>' scheme has been added/updated with the following")
      mail.should have_body_text("Total points: <strong>1200</strong>")
      mail.should have_body_text("Your current contact details as per our records are:")
      mail.should have_body_text("Name: <strong>#{user.full_name}</strong>")
      mail.should have_body_text("User Name: <strong>#{user.username}</strong>")
      mail.should have_body_text("Participant ID: <strong>#{user.participant_id}</strong>")
      mail.should have_body_text("Mobile Number: <strong>#{user.mobile_number}</strong>")
      mail.should have_body_text("Land line Number: <strong>#{user.landline_number}</strong>")
      mail.should have_body_text("Address: <strong>#{user.address}, #{user.pincode}</strong>")
      mail.should have_link("Contact Us", :href => "http://localhost/contact_us")
    end

    it 'should send email for users current achievement update' do
      user = Fabricate(:user, :email => 'user@me.com')

      UserMailer.any_instance.should_receive(:sendgrid_category).with('Participant Account Update')
      UserMailer.any_instance.should_receive(:sendgrid_unique_args).with(:scheme => "scheme_name", :participant_id => user.participant_id)

      mail = UserMailer.account_update(user, "scheme_name", {:current_achievements => 1200})

      mail.should deliver_to(user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{user.client.client_name} Rewards Program - Account Update Notification")

      mail.should have_body_text("Dear #{user.full_name}")
      mail.should have_body_text("Your '<strong>scheme_name</strong>' scheme has been added/updated with the following")
      mail.should have_body_text("Current achievements: <strong>1200</strong>")
      mail.should have_link("Contact Us", :href => "http://localhost/contact_us")
    end

    it 'should send email for one time password' do
      user = Fabricate(:user, :email => 'user@me.com')
      user.otp_secret_key = ROTP::Base32.random_base32
      user.save

      UserMailer.any_instance.should_receive(:sendgrid_category).with('Participant One Time Password')
      UserMailer.any_instance.should_receive(:sendgrid_unique_args).with(:participant_id => user.participant_id)

      otp_code = user.otp_code

      mail = UserMailer.send_one_time_password(user, otp_code)

      mail.should deliver_to(user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{user.client.client_name} Rewards Program - One Time Password")

      mail.should have_body_text("Dear #{user.full_name}")
      mail.should have_body_text("You have attempted to redeem your products.")
      mail.should have_body_text("One Time Password to Redeem your Products is:")
      mail.should have_body_text("#{otp_code}")
      mail.should have_body_text("Please use this password to confirm your Order.")
      mail.should have_link("Contact Us", :href => "http://localhost/contact_us")
    end

  end

  context "client with subdomain" do
    it 'should send email with account activation link with correct subdomain if client has subdomain specfied' do
      client = Fabricate(:client, :domain_name => "axis.bvc.com" )
      user = Fabricate(:user, :email => 'user@me.com', :client => client)

      mail = UserMailer.send_account_activation_link(user)

      mail.should have_body_text("http://axis.bvc.com/users/password/edit?mode=activate")
      mail.should have_link("Contact Us", :href => "http://axis.bvc.com/contact_us")

    end

    it 'should send email for users current achievement update with correct subdomain if client has subdomain specfied' do
      client = Fabricate(:client, :domain_name => "axis.bvc.com" )
      user = Fabricate(:user, :email => 'user@me.com', :client => client)

      mail = UserMailer.account_update(user, "scheme_name", {:current_achievements => 1200})

      mail.should have_body_text("http://axis.bvc.com/")
      mail.should have_link("Contact Us", :href => "http://axis.bvc.com/contact_us")

    end
    it 'should send email for account update with correct subdomain if client has subdomain specfied' do
      client = Fabricate(:client, :domain_name => "emerson.bvc.com" )
      user = Fabricate(:user, :email => 'user@me.com', :client => client)

      mail = UserMailer.account_update(user, "scheme_name", {:total_points => 1200})

      mail.should have_link("here", :href => "http://emerson.bvc.com/")
      mail.should have_link("Contact Us", :href => "http://emerson.bvc.com/contact_us")
    end
  end
end
