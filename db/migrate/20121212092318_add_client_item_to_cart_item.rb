class AddClientItemToCartItem < ActiveRecord::Migration
  def change
    remove_column :cart_items, :item_id
    add_column :cart_items, :client_item_id, :integer
  end
end
