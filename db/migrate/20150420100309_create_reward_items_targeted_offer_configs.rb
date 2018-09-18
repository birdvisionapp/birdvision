class CreateRewardItemsTargetedOfferConfigs < ActiveRecord::Migration
  def change
    create_table :reward_items_targeted_offer_configs do |t|
      t.integer  "reward_item_id"
      t.integer  "targeted_offer_config_id"
      t.timestamps
    end
  end
end
