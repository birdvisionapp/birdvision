class AddBvcAndChannelPriceToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :bvc_price, :integer
    add_column :order_items, :channel_price, :integer
  end
end
