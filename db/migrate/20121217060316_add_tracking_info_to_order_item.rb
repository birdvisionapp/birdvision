class AddTrackingInfoToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :shipping_agent, :string
    add_column :order_items, :shipping_code, :string
  end
end
