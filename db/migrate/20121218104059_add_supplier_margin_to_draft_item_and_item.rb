class AddSupplierMarginToDraftItemAndItem < ActiveRecord::Migration
  def change
    add_column :draft_items, :supplier_margin, :float
    add_column :items, :supplier_margin, :float
  end
end
