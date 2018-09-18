class AddAttributesToClientManager < ActiveRecord::Migration
  def change
    add_column :client_managers, :name, :string
    add_column :client_managers, :email, :string
    add_column :client_managers, :mobile_number, :string
    change_column :client_managers, :admin_user_id, :integer, :null => true
    change_column :client_managers, :client_id, :integer, :null => true
  end
end
