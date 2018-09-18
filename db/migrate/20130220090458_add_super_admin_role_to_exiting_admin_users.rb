class AddSuperAdminRoleToExitingAdminUsers < ActiveRecord::Migration
  def up
    AdminUser.reset_column_information
    AdminUser.all.each { |admin_user| admin_user.update_attributes(:role => AdminUser::Roles::SUPER_ADMIN) unless admin_user.reseller.present? }
  end
end
