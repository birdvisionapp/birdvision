class RenamePriceToMrp < ActiveRecord::Migration
  def change
    rename_column :draft_items, :price, :mrp
    rename_column :items, :price, :mrp
  end
end
