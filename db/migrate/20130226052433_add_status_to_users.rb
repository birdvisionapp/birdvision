class AddStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activation_status, :string
    User.all.each do |user|
      if user.encrypted_password.present?
        user.update_attributes!(:activation_status => User::ActivationStatus::ACTIVATED)
      elsif not user.encrypted_password.present? and user.reset_password_token.present?
        user.update_attributes!(:activation_status => User::ActivationStatus::NOT_ACTIVATED)
      elsif not user.encrypted_password.present? and not user.reset_password_token.present?
        user.update_attributes!(:activation_status => User::ActivationStatus::LINK_NOT_SENT)
      end
    end
  end
end