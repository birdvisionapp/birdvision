class CreateRewardItemPoints < ActiveRecord::Migration
  def change
    create_table :reward_item_points do |t|
      t.integer :reward_item_id
      t.integer :points
      t.string :pack_size
      t.string :metric
      t.string :status, :default => RewardItemPoint::Status::ACTIVE
      t.timestamps
    end
    add_index :reward_item_points, :reward_item_id
    add_index :reward_item_points, :status
  end
end
