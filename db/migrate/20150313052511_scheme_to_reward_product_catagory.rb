class SchemeToRewardProductCatagory < ActiveRecord::Migration
  def change
    add_column :reward_product_catagories, :scheme_id, :integer
    add_index :reward_product_catagories, :scheme_id
  end
end
