class AssociateSchemeWithOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :scheme_id, :integer , :null => false, :default => -1
    change_column_default(:order_items, :scheme_id, nil)
  end
end
