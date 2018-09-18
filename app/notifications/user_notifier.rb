class UserNotifier
  def self.notify_activation(user)
    return nil unless user.email.present?
    UserMailer.delay.send_account_activation_link(user)
    SmsMessage.new(:account_registration, :to => user.mobile_number, :client => user.client.client_name, :email => user.email).delay.deliver if user.mobile_number.present?
  end
  
  def self.notify_sms_based_registration_hal(user)
    SmsMessage.new(:hal_registration_sms, :to => user.mobile_number, :client => user.client.client_name, :balance => user.total_redeemable_points).delay.deliver if user.mobile_number.present?
  end
  
  def self.notify_sms_based_registration(user)
    if user.client_id != 261
      SmsMessage.new(:account_registration_sms_based, :to => user.mobile_number, :client => user.client.client_name, :balance => user.total_redeemable_points).delay.deliver if user.mobile_number.present?
    else
      SmsMessage.new(:l_and_t_registration_sms_based, :to => user.mobile_number, :client => user.client.client_name, :balance => user.total_redeemable_points).delay.deliver if user.mobile_number.present?
    end
  end

  def self.notify_activation_complete(user)
    UserMailer.delay.account_activation(user) if user.encrypted_password_was.empty? && user.email.present?
    domain_name = user.client.domain_name.presence || Rails.application.config.action_mailer.default_url_options[:host]
    SmsMessage.new(:account_activation, :to => user.mobile_number, :username => user.username, :domain => domain_name, :client => user.client.client_name).delay.deliver if user.encrypted_password_was.empty? && user.mobile_number.present?
  end

  def self.notify_one_time_password(user)
    otp_code = user.otp_code
    UserMailer.delay.send_one_time_password(user, otp_code) if user.client.allow_otp_email? && user.email.present?
    SmsMessage.new(:one_time_password, :to => user.mobile_number, :username => user.username, :otp_code => otp_code, :client => user.client.client_name).delay.deliver if user.client.allow_otp_mobile? && user.mobile_number.present?
  end

  def self.notify_balance(user)
    point_transactions = user.scheme_transactions.credit.where('DATE(created_at) = ?', Date.yesterday).select(:points)
    points = point_transactions.sum(:points) if point_transactions.present?
    SmsMessage.new(:points_are_added, :to => user.mobile_number, :client => user.client.client_name, :points => points, :balance => user.total_redeemable_points).delay.deliver if user.mobile_number.present? && points.present? && points > 0
  end

  def self.notify_to(user, template_details)
    user = user
    template = template_details
    UserMailer.delay.to_applicable_user(user, template) if user.email.present?
  end

  def self.notify_birthday_to(user)
    UserMailer.delay.to_birthday_user(user) if user.email.present?
  end

  def self.notify_extra_point_updated(user, incentive_detail_point, product_id)
    user = User.find(user.id)
    product_name = RewardItem.find(product_id).name
    SmsMessage.new(:to_template_8, :to => user.mobile_number, :user_name => user.full_name, :client_name => user.client.client_name, :extra_points => incentive_detail_point, :product_name => product_name).delay.deliver if user.mobile_number.present?
  end
  
  def self.notify_participant_registration(user)
    return nil unless user.email.present?
    UserMailer.delay.notify_participant_registration_details(user)
  end
  
end