class ChangeColumnRewardProductCatagoriesIdFromRewardItems < ActiveRecord::Migration
  def change
    rename_column :reward_items, :reward_product_catagories_id, :reward_product_catagory_id
  end
end
