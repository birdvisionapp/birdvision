class AddRedemptionTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :redemption_type, :string
  end
end
