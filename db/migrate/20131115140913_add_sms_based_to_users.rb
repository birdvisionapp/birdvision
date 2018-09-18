class AddSmsBasedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sms_based, :boolean, :default => false
    add_index :users, :sms_based
  end
end
