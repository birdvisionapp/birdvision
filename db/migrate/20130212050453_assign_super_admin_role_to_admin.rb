class AssignSuperAdminRoleToAdmin < ActiveRecord::Migration
  def up
    AdminUser.all.each{|admin_user| admin_user.update_attributes(:role => AdminUser::Roles::SUPER_ADMIN)}
  end

  def down
  end
end
