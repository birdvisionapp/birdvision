class CreateDraftItems < ActiveRecord::Migration
  def change
    create_table :draft_items do |table|
      table.string "supplier_name", :null => false
      table.string "item_name", :null => false
      table.string "listing_id", :null => false
      table.string "model_no", :null => false
      table.integer "mrp", :null => false
      table.integer "channel_price", :null => false
      table.string "description"
      table.timestamps
    end
  end
end
