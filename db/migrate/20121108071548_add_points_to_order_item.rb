class AddPointsToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :points, :integer ,:default=>0,:null=>false
  end
end
