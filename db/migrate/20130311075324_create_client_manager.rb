class CreateClientManager < ActiveRecord::Migration
  def change
    create_table :client_managers do |t|
      t.references :client, :null => false
      t.references :admin_user, :null=>false
    end
    add_foreign_key "client_managers", "clients", :name => "client_managers_client_id_fk"
    add_foreign_key "client_managers", "admin_users", :name => "client_managers_admin_user_id_fk"
  end
end
