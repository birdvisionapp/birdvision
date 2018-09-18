class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :resellers, :admin_user_id
    add_index :level_clubs, :scheme_id
    add_index :level_clubs, [:level_id, :scheme_id]
    add_index :level_clubs, [:club_id, :scheme_id]
    add_index :cart_items, :client_item_id
    add_index :cart_items, :cart_id
    add_index :client_items, :item_id
    add_index :client_items, :client_catalog_id
    add_index :catalog_items, :client_item_id
    add_index :carts, :user_scheme_id
    add_index :client_resellers, :client_id
    add_index :client_resellers, :reseller_id
    add_index :client_resellers, [:client_id, :reseller_id]
    add_index :clients, :client_catalog_id
    add_index :draft_items, :category_id
    add_index :draft_items, :supplier_id
    add_index :items, :category_id
    add_index :user_schemes, :user_id
    add_index :user_schemes, :scheme_id
    add_index :user_schemes, :level_id
    add_index :user_schemes, :club_id
    add_index :order_items, :order_id
    add_index :order_items, :client_item_id
    add_index :order_items, :scheme_id
    add_index :order_items, :supplier_id
    add_index :users, :client_id
    add_index :users, :user_role_id
    add_index :orders, :user_id
    add_index :slabs, :client_reseller_id
    add_index :client_managers, :admin_user_id
    add_index :client_managers, :client_id
    add_index :schemes, :client_id
    add_index :targets, :user_scheme_id
    add_index :targets, :club_id
  end

end
