class CreateRewardProductCatagories < ActiveRecord::Migration
  def change
    create_table :reward_product_catagories do |t|
      t.belongs_to :client
      t.string :category_name
      t.string :category_description
      t.timestamps
    end
  end
end
