class RemoveClientNameFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :client_name
  end
end
