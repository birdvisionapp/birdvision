class ClientMailer < ActionMailer::Base
  helper :mail_url
  default :from => "no-reply@birdvision.in"
  include SendGrid

  def balance_reminder client, recipient, options = {}
    sendgrid_category 'Client Points Balance Reminder'
    sendgrid_unique_args :client_id => client.id, :client_code => client.code
    @client = client
    @options = options
    mail :to => recipient, :subject => "Your #{APP_TITLE} Balance is low", :template_path => "mailers/client"
  end
end
