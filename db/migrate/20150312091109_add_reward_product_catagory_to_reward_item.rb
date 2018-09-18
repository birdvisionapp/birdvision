class AddRewardProductCatagoryToRewardItem < ActiveRecord::Migration
  def change
    add_column :reward_items, :reward_product_catagories_id, :integer
    add_index :reward_items, :reward_product_catagories_id
  end
end
