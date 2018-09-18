class AddExpiryDateToClients < ActiveRecord::Migration
  def change
    add_column :clients, :expiry_date, :date
    add_index :clients, :expiry_date
  end
end
