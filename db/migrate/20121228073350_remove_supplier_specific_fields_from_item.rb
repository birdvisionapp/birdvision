class RemoveSupplierSpecificFieldsFromItem < ActiveRecord::Migration
  def change
    remove_column :items, :supplier_id
    remove_column :items, :geographic_reach
    remove_column :items, :delivery_time
    remove_column :items, :available_quantity
    remove_column :items, :available_till_date
    remove_column :items, :channel_price
    remove_column :items, :listing_id
    remove_column :items, :supplier_margin
    remove_column :items, :mrp
  end
end
