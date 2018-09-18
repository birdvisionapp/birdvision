class UserMailer < ActionMailer::Base
  helper :mail_url
  helper :application
  default :from => "no-reply@birdvision.in"
  include SendGrid

  def send_account_activation_link user
    sendgrid_category 'Participant Account Activation'
    sendgrid_unique_args :participant_id => user.participant_id
    @user = user
    mail :to => @user.email, :subject => "#{@user.client.client_name} Rewards Program - Account Activation Details", :template_path => "mailers/user"
  end

  def account_activation user
    sendgrid_category 'Participant Account Confirmation'
    sendgrid_unique_args :participant_id => user.participant_id
    @user = user
    mail :to => @user.email, :subject => "#{@user.client.client_name} Rewards Program - Account Details", :template_path => "mailers/user"
  end

  def account_update user, scheme_name, change_hash
    sendgrid_category 'Participant Account Update'
    sendgrid_unique_args :scheme => scheme_name, :participant_id => user.participant_id
    @user = user
    @scheme_name = scheme_name
    @change_hash = change_hash
    mail :to => @user.email, :subject => "#{@user.client.client_name} Rewards Program - Account Update Notification", :template_path => "mailers/user"
  end

  def send_one_time_password user, otp_code
    sendgrid_category 'Participant One Time Password'
    sendgrid_unique_args :participant_id => user.participant_id
    @user = user
    @otp_code = otp_code
    mail :to => @user.email, :subject => "#{@user.client.client_name} Rewards Program - One Time Password", :template_path => "mailers/user"
  end

  def total_points_deduction user_scheme, points_deducted, balance
    sendgrid_category 'Participant Total Points Deduction'
    sendgrid_unique_args :user_scheme_id => user_scheme.id
    @user = user_scheme.user
    @points_deducted = points_deducted
    @balance = balance
    mail :to => @user.email, :subject => "#{@user.client.client_name} Rewards Program - Points Deduction Notification", :template_path => "mailers/user"
  end

  def to_applicable_user user, template
    sendgrid_category 'Reward Program Benefits'
    sendgrid_unique_args :participant_id => user.participant_id
    @user = user
    @template = template
    mail :to => @user.email, :subject => "#{@user.client.client_name} Rewards Program - Extra Benefits On Purchase", :template_path => "mailers/user"
  end

  def to_birthday_user user
    sendgrid_category 'Happy Birthday'
    sendgrid_unique_args :participant_id => user.participant_id
    @user = user
    mail :to => @user.email, :subject => "#{@user.client.client_name} Rewards Program - Happy Birthday", :template_path => "mailers/user"
  end
  
  def notify_participant_registration_details user
    sendgrid_category 'New Participant Registration'
    @user = user
    @password = user.password
    mail :to => @user.email, :subject => "#{APP_TITLE} - Account Details", :template_path => "mailers/user"
  end
  
  def al_user_change_request user, details
    sendgrid_category 'AL User Change Request'
    sendgrid_unique_args :participant_id => user.participant_id
    @user = user
    @details = details
    mail :to => "Leyparts.Priority@ashokleyland.com", :subject => "AL DOST Program", :template_path => "mailers/user"
  end

end