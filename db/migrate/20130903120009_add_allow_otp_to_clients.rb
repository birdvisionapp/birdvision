class AddAllowOtpToClients < ActiveRecord::Migration
  def change
    add_column :clients, :allow_otp, :boolean
    add_column :clients, :allow_otp_email, :boolean
    add_column :clients, :allow_otp_mobile, :boolean
    add_column :clients, :otp_code_expiration, :integer
    add_index :clients, :allow_otp
    add_index :clients, :allow_otp_email
    add_index :clients, :allow_otp_mobile
  end
end
