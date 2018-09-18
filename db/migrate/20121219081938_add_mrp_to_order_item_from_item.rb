class AddMrpToOrderItemFromItem < ActiveRecord::Migration
  def change
    change_column :draft_items, :mrp, :float
    add_column :order_items, :mrp, :float
  end
end
