class AddClientItemAttributesToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :sent_to_supplier_date, :datetime
    add_column :order_items, :sent_for_delivery, :datetime
    add_column :order_items, :points_claimed, :integer
    add_column :order_items, :price_in_rupees, :integer
    add_column :order_items, :bvc_margin, :float
  end
end
