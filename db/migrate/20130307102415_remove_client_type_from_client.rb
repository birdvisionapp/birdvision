class RemoveClientTypeFromClient < ActiveRecord::Migration
  def change
    remove_column :clients, :client_type
  end
end
