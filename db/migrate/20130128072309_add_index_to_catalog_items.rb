class AddIndexToCatalogItems < ActiveRecord::Migration
  def change
    add_index :catalog_items, :catalog_owner_id
    add_index :catalog_items, :catalog_owner_type
  end
end