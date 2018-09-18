class AddSmsBasedToClients < ActiveRecord::Migration
  def change
    add_column :clients, :sms_based, :boolean, :default => false
    add_index :clients, :sms_based
    add_column :admin_users, :deleted, :boolean, :default => false
    add_index :admin_users, :deleted
  end
end
