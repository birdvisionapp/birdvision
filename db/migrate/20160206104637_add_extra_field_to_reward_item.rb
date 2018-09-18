class AddExtraFieldToRewardItem < ActiveRecord::Migration
  def change
  	add_column :reward_items, :al_part_no, :string
  end
end
