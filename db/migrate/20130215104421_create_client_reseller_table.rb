class CreateClientResellerTable < ActiveRecord::Migration

  def change
    create_table :client_resellers do |t|
      t.references :client, :null => false
      t.references :reseller, :null => false
      t.integer :finders_fee
      t.date :payout_start_date
      t.float :finders_fee
      t.timestamps
    end
    add_foreign_key "client_resellers", "clients", :name => "client_resellers_client_id_fk"
    add_foreign_key "client_resellers", "resellers", :name => "client_resellers_reseller_id_fk"
  end
end
