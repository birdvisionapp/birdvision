class CreatePackTierConfigs < ActiveRecord::Migration
  def change
    create_table :pack_tier_configs do |t|
      t.integer :reward_item_point_id, :null => false
      t.integer :user_role_id, :null => false
      t.integer :codes, :null => false
      t.string :tier_name

      t.timestamps
    end
    add_index :pack_tier_configs, :reward_item_point_id
    add_index :pack_tier_configs, :user_role_id
  end
end
