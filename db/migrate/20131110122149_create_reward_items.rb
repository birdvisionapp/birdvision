class CreateRewardItems < ActiveRecord::Migration
  def change
    create_table :reward_items do |t|
      t.integer :client_id
      t.integer :scheme_id
      t.string :name
      t.string :status
      t.timestamps
    end
    add_index :reward_items, :client_id
    add_index :reward_items, :scheme_id
    add_index :reward_items, :status
  end
end
