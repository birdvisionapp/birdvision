class AddOtpSecretKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :otp_secret_key, :string
    add_index :users, :otp_secret_key
  end
end
