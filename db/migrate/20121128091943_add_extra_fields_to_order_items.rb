class AddExtraFieldsToOrderItems < ActiveRecord::Migration
  change_table :order_items do |table|
    table.timestamps
    table.string :status, :default => "new"
  end
end
