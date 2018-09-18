class AddingClientResellerAssociation < ActiveRecord::Migration
  def change
    create_table :clients_resellers, :id => false do |t|
      t.integer :client_id
      t.integer :reseller_id
    end

    add_index :clients_resellers, [:client_id, :reseller_id], :unique => true
  end
end
