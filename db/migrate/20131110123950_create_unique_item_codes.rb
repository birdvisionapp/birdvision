class CreateUniqueItemCodes < ActiveRecord::Migration
  def change
    create_table :unique_item_codes do |t|
      t.integer :reward_item_id
      t.string :code
      t.date :expiry_date
      t.integer :user_id, :null => true
      t.datetime :used_at, :null => true
      t.datetime :created_at
    end
    add_index :unique_item_codes, :reward_item_id
    add_index :unique_item_codes, :code, :unique => true
    add_index :unique_item_codes, :expiry_date
    add_index :unique_item_codes, :user_id
    add_index :unique_item_codes, :used_at
  end
end
