class AddRewardItemPointToAlTransactions < ActiveRecord::Migration
  def change
  	add_column :al_transactions, :reward_item_point_id, :integer
  end
end
