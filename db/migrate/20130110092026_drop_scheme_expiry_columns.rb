class DropSchemeExpiryColumns < ActiveRecord::Migration
  def change
    remove_column :schemes, :point_expiry, :catalog_expiry
  end
end
