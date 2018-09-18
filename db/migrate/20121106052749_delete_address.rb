class DeleteAddress < ActiveRecord::Migration
  def up
    remove_column :orders, :address_id
    drop_table :addresses
  end

  def down
  end
end
