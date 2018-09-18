class AddSupplierSpecificDraftItemDetails < ActiveRecord::Migration
  def change
    add_column :draft_items, :geographic_reach, :string
    add_column :draft_items, :delivery_time, :string
    add_column :draft_items, :available_quantity, :integer
    add_column :draft_items, :available_till_date, :datetime

    add_column :items, :geographic_reach, :string
    add_column :items, :delivery_time, :string
    add_column :items, :available_quantity, :integer
    add_column :items, :available_till_date, :datetime
  end
end
