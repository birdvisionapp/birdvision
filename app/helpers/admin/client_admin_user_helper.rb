module Admin::ClientAdminUserHelper

  def email_password_reset_instructions_to(client_admin_user)
    client_admin_user.admin_user.update_attributes!(:reset_password_token => AdminUser.reset_password_token, :reset_password_sent_at => DateTime.current)
    ClientAdminUserMailer.delay.send_account_activation_link(client_admin_user)
  end
  
  def create_admin_user
    return if admin_user.present?
    role = self.type
    username = "#{client.code}_#{role_code(role)}.#{id}"
    user_params = {:username => username, :email => email, :role => role.underscore}
    user_params.merge!(:msp_id => client.msp_id) if client.msp_id.present?
    self.admin_user = AdminUser.create!(user_params)
    save!
  end

  def send_creation_email
    email_password_reset_instructions_to(self)
  end

  def sync_admin
    if admin_user.present?
      admin_user.update_attributes!(:email => self.email)
      RegionalManagersTelecomCircle.includes(:regional_manager).where('regional_managers.client_id = ? AND regional_managers_telecom_circles.regional_manager_id != ? AND regional_managers_telecom_circles.telecom_circle_id IN(?)', self.client_id, self.id, self.telecom_circle_ids).destroy_all if self.id.present? && self.telecom_circle_ids.present? && admin_user.regional_manager?
    end
  end

  def associated_client_for admin_user
    for_admin_user(admin_user).client
  end

  def for_admin_user admin_user
    where(:admin_user_id => admin_user.id).first
  end

  private

  def role_code(role)
    case(role)
    when 'RegionalManager'
      'rm'
    when 'Representative'
      'lsr'
    end
  end

end
