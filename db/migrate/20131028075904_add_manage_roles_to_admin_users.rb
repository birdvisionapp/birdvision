class AddManageRolesToAdminUsers < ActiveRecord::Migration
  
  def up
    add_column :admin_users, :manage_roles, :boolean, :default => false
    add_index :admin_users, :manage_roles
    add_column :admin_users, :is_locked, :boolean, :default => false
    add_index :admin_users, :is_locked
    admin_user = AdminUser.where(:username => 'admin', :role => AdminUser::Roles::SUPER_ADMIN).first
    admin_user.update_attribute(:manage_roles, true) if admin_user.present?
  end
  
  def down    
    remove_column :admin_users, :manage_roles
    remove_column :admin_users, :is_locked
  end

end
