class AssociateClientItemToOrderItem < ActiveRecord::Migration
  def change
    remove_column :order_items, :item_id
    add_column :order_items, :client_item_id, :integer
  end
end
