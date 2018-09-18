class AddAllowSsoToClients < ActiveRecord::Migration
  def change
    add_column :clients, :allow_sso, :boolean
    add_index :clients, :allow_sso
  end
end
