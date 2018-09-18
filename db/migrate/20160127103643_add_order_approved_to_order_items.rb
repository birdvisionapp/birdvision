class AddOrderApprovedToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :order_approved, :boolean
  end
end
