class AddTimestampToCartItems < ActiveRecord::Migration
  def change
    change_table :cart_items do |table|
      table.timestamps
    end
  end
end
