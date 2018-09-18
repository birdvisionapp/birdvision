class AddClientKeySecretToClients < ActiveRecord::Migration
  def change
    add_column :clients, :client_key, :string
    add_column :clients, :client_secret, :string
    add_column :clients, :client_url, :string
    add_index :clients, [:client_key, :client_secret], :unique => true
  end
end
