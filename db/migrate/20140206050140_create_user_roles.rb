class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.integer :client_id, :null => false
      t.string :name, :null => false
      t.string :ancestry
      
      t.timestamps
    end
    add_index :user_roles, :client_id
    add_index :user_roles, :name
    add_index :user_roles, :ancestry
    add_column :users, :user_role_id, :integer
  end
end
