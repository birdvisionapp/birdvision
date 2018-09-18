class RemoveUnusedColumnsFromReseller < ActiveRecord::Migration
  def change
    remove_column :resellers, :finders_fee
    remove_column :resellers, :payout_start_date
  end
end
