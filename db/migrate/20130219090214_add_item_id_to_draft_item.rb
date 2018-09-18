class AddItemIdToDraftItem < ActiveRecord::Migration
  def change
    change_table :draft_items do |t|
      t.references :item
    end
  end
end
