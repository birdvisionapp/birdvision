class AddStatusToItems < ActiveRecord::Migration
  def change
    add_column :items, :status, :string, :default => Item::Status::ACTIVE
    add_index :items, :status
  end
end
