class AddMspIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :msp_id, :integer
    add_column :suppliers, :msp_id, :integer
    add_column :categories, :msp_id, :integer
    add_column :admin_users, :msp_id, :integer
    add_index :clients, :msp_id
    add_index :suppliers, :msp_id
    add_index :categories, :msp_id
    add_index :admin_users, :msp_id
  end
end
