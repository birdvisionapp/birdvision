class AddRewardItemPointToUniqueItemCodes < ActiveRecord::Migration
  def self.up
    add_column :unique_item_codes, :reward_item_point_id, :integer
    add_index :unique_item_codes, :reward_item_point_id
    remove_column :unique_item_codes, :reward_item_id
  end

  def self.down
    remove_column :unique_item_codes, :reward_item_point_id
    add_column :unique_item_codes, :reward_item_id, :integer
    add_index :unique_item_codes, :reward_item_id
  end
end
