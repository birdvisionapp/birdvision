class AddTypeToRegionalManagers < ActiveRecord::Migration

  def change
    add_column :regional_managers, :type, :string
    add_column :regional_managers, :address, :text
    add_column :regional_managers, :pincode, :string
    add_index :regional_managers, :type
  end

end
