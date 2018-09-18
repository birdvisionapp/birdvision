class AssociateUserToAClient < ActiveRecord::Migration
  def change
    change_table :users do |table|
      table.references :client, :null => false, :unique => true, :default => -1
    end
    change_column_default(:users, :client_id, nil)
  end
end
