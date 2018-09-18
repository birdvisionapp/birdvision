class AddTimeStampToClientItems < ActiveRecord::Migration
  def change
    change_table :client_items do |table|
      table.timestamps
    end
  end
end
