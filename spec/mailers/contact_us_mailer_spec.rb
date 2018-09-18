require "spec_helper"

describe ContactUsMailer do
  context 'mail' do

    it 'should send email to birdvision customer care when someone submits contact us page' do
      ContactUsMailer.any_instance.should_receive(:sendgrid_category).with('Contact Us')
      ContactUsMailer.any_instance.should_receive(:sendgrid_unique_args).with(:email => 'email@email.com')

      mail = ContactUsMailer.send_mail ({:name => "Prem Chopra", :email => "email@email.com", :message => "Contact mail"})

      mail.should deliver_to("birdvision@mailinator.com")
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("Contact Request")

      mail.should have_body_text("Name: <strong>Prem Chopra</strong>")
      mail.should have_body_text("Email: <strong>email@email.com</strong>")
      mail.should have_body_text("Message: Contact mail")
    end
  end
end
