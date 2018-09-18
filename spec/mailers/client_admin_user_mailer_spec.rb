require "spec_helper"

describe ClientAdminUserMailer do
  context 'mail' do

    it 'should send email with account activation link' do
      client_manager = Fabricate(:client_manager, :email => 'client_manager@me.com')
      ClientAdminUserMailer.any_instance.should_receive(:sendgrid_category).with('Client Manager Account Activation')

      mail = ClientAdminUserMailer.send_account_activation_link(client_manager)

      mail.should deliver_to(client_manager.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("Client Manager - Account Activation Details")

      mail.should have_body_text("Dear #{client_manager.name}")
      mail.should have_body_text("We are pleased to inform you that")
      mail.should have_body_text("Username")
      mail.should have_body_text("#{client_manager.admin_user.username}")

      mail.should have_body_text("Please save your username for all future reference and communication.")
    end
  end
end
