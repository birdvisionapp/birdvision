class CreateRegionalManagers < ActiveRecord::Migration
  def change
    create_table :regional_managers do |t|
      t.integer :client_id
      t.integer :admin_user_id
      t.string :region, :limit => 32
      t.string :name, :limit => 32
      t.string :mobile_number, :limit => 32
      t.string :email, :limit => 46
      t.timestamps
    end
    add_index :telecom_circles, :code
    add_index :regional_managers, :client_id
    add_index :regional_managers, :admin_user_id
  end
end
