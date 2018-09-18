class ContactUsMailer < ActionMailer::Base
  #default :to => CONTACT_US_RECIPIENT
  #default :from => "no-reply@birdvision.in"
  include SendGrid

  def send_mail to, user_info
    sendgrid_category 'Contact Us'
    sendgrid_unique_args :email => user_info[:email]
    @user_info = user_info
    mail :to => to, :from => user_info[:email], :subject => "Contact Request", :template_path => "mailers/contact_us"
  end
end
