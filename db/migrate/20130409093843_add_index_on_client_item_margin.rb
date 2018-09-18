class AddIndexOnClientItemMargin < ActiveRecord::Migration
  def change
    add_index :client_items, :margin

    add_index :catalog_items, [:catalog_owner_id, :catalog_owner_type]
  end
end
