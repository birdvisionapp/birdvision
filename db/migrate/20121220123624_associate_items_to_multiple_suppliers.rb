class AssociateItemsToMultipleSuppliers < ActiveRecord::Migration
  def change
    create_table :item_suppliers do |t|
      t.references :item, :null => false
      t.references :supplier, :null => false

      t.string :geographic_reach
      t.string :delivery_time
      t.integer :available_quantity
      t.time :available_till_date
      t.integer :channel_price
      t.integer :listing_id
      t.float :supplier_margin
      t.float :mrp
      t.string :model_no
      t.boolean :is_preferred, :default=>false
    end

  end
end
