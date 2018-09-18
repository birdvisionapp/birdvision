class AddAddressToClients < ActiveRecord::Migration
  def change
    add_column :clients, :address, :text
  end
end
