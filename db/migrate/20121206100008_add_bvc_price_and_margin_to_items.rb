class AddBvcPriceAndMarginToItems < ActiveRecord::Migration
  def change
    add_column :items, :bvc_price, :integer
    add_column :items, :margin, :integer
  end
end
