class AddExtraFieldsToDraftItems < ActiveRecord::Migration
  def change
    add_column :draft_items, :specification, :string
    add_column :draft_items, :brand, :string
  end
end
