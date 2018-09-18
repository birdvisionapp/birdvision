class AddPackTierConfigIdToUniqueItemCodes < ActiveRecord::Migration

  def change
    add_column :unique_item_codes, :pack_tier_config_id, :integer, :null => true
    add_index :unique_item_codes, :pack_tier_config_id
    add_column :unique_item_codes, :ancestry, :string
    add_index :unique_item_codes, :ancestry
    add_column :unique_item_codes, :pack_number, :integer
  end

end
