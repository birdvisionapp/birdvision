class CreateCatalogAndUpdateAssociations < ActiveRecord::Migration
  def change
    create_table :client_catalogs do |t| 

    end

    add_column :clients, :client_catalog_id, :integer
    add_column :client_items, :client_catalog_id, :integer, :null => false, :default => -1
    change_column_default(:client_items, :client_catalog_id, nil)
    remove_column :client_items, :client_id
  end
end
