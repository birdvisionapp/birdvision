class ChangeColumnsInItemSuppliersAsPerDraftItems < ActiveRecord::Migration
  def up
    change_column :item_suppliers, :available_till_date, :datetime
    change_column :item_suppliers, :listing_id, :string
  end

  def down
    change_column :item_suppliers, :available_till_date, :time
    change_column :item_suppliers, :listing_id, :integer
  end
end
