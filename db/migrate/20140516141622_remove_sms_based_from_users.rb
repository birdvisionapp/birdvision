class RemoveSmsBasedFromUsers < ActiveRecord::Migration

  def up
    remove_column :users, :sms_based
  end

  def down
    add_column :users, :sms_based, :boolean, :default => false
    add_index :users, :sms_based
  end

end
