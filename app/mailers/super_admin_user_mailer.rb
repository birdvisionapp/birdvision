class SuperAdminUserMailer < ActionMailer::Base
  helper :mail_url
  default :from => "no-reply@birdvision.in"
  include SendGrid

  def send_account_confirmation admin_user
    sendgrid_category 'Admin Account Confirmation'
    @admin_user = admin_user
    mail :to => @admin_user.email, :subject => "#{APP_TITLE} - Account Details", :template_path => "mailers/admin_user"
  end

  def send_account_activation_link admin_user
    sendgrid_category 'Admin Account Activation'
    @admin_user = admin_user
    mail :to => admin_user.email, :subject => "#{admin_user.username} - Account Activation Details", :template_path => "mailers/admin_user"
  end

  def send_change_password_confirmation admin_user, new_password
    sendgrid_category 'Admin Change Password Confirmation'
    @admin_user = admin_user
    @new_password = new_password
    mail :to => @admin_user.email, :subject => "#{APP_TITLE} - Account Details", :template_path => "mailers/admin_user"
  end

end
