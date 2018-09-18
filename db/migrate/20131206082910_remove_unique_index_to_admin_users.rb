class RemoveUniqueIndexToAdminUsers < ActiveRecord::Migration
  def up
    remove_index :admin_users, :username
    add_index :admin_users, :username
  end

  def down
    remove_index :admin_users, :username
    add_index :admin_users, :username, :unique => true
  end
end
