class ClientAdminUserMailer < ActionMailer::Base
  helper :mail_url
  default :from => "no-reply@birdvision.in"
  include SendGrid

  # The client_admin_user object passed should respond to admin_user
  def send_account_activation_link client_admin_user
    @user = client_admin_user
    @admin_user = client_admin_user.admin_user
    sendgrid_category "#{@admin_user.role.titleize} Account Activation"
    mail :to => @admin_user.email, :subject => "#{@admin_user.role.titleize} - Account Activation Details", :template_path => "mailers/client_admin_user"
  end
end
