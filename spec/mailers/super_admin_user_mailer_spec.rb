require "spec_helper"

describe SuperAdminUserMailer do

  it 'should send email with account activation link' do
    admin_user = Fabricate(:admin_user, :email => 'admin@bvc.in')
    SuperAdminUserMailer.any_instance.should_receive(:sendgrid_category).with('Admin Account Activation')

    mail = SuperAdminUserMailer.send_account_activation_link(admin_user)

    mail.should deliver_to(admin_user.email)
    mail.should deliver_from("no-reply@birdvision.in")
    mail.should have_subject("#{admin_user.username} - Account Activation Details")
    mail.should have_body_text("#{admin_user.username}")
    mail.should have_body_text("Please save your username for all future reference and communication.")
    mail.should have_link("here", :href => edit_admin_user_password_url(admin_user, :reset_password_token => admin_user.reset_password_token, :mode => "activate"))
  end

  it 'should send email on account confirmation' do
    admin_user = Fabricate(:admin_user, :email => 'admin@bvc.in')
    admin_user.password = "new password"
    admin_user.save
    SuperAdminUserMailer.any_instance.should_receive(:sendgrid_category).with('Admin Account Confirmation')

    mail = SuperAdminUserMailer.send_account_confirmation(admin_user)

    mail.should deliver_to(admin_user.email)
    mail.should deliver_from("no-reply@birdvision.in")
    mail.should have_subject("Birdvision - Account Details")
    mail.should have_body_text("Your account details are as follows:")
    mail.should have_body_text("Username for login:")
    mail.should have_body_text("#{admin_user.username}")
    mail.should have_body_text("You can sign in to your account by clicking the following link:")
  end
end
