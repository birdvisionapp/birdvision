class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, :null => false, :default => ""
    change_column :users, :email, :string, :null => true
    remove_index :users, :email
    add_index :users, :username, :unique => true
  end
end