class AddIndexToItemSuppliers < ActiveRecord::Migration
  def change
    add_index :item_suppliers, [:item_id, :supplier_id], :unique => true
  end
end
