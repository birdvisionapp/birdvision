class AddIsLiveToClients < ActiveRecord::Migration
  def change
    add_column :clients, :is_live, :boolean
    add_index :clients, :is_live
  end
end
