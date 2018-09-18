class AddDraftItemsInfoToItems < ActiveRecord::Migration
  def change
    add_column :items, :listing_id, :string
    add_column :items, :model_no, :string
    add_column :items, :channel_price, :integer
    add_column :items, :supplier_id, :integer
    add_column :items, :specification, :text, :limit => 30000
    add_column :items, :brand, :string
    rename_column :draft_items, :mrp, :price
    rename_column :draft_items, :item_name, :title
  end
end