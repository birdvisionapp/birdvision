class AddColorHexToUserRoles < ActiveRecord::Migration
  def change
    add_column :user_roles, :color_hex, :string, :null => true
  end
end
