class AddClientResellerToSlabAssociation < ActiveRecord::Migration
  def change
    remove_foreign_key(:slabs, :reseller)
    remove_column :slabs, :reseller_id

    change_table :slabs do |t|
      t.references :client_reseller
    end
    add_foreign_key "slabs", "client_resellers", :name => "slabs_client_reseller_id_fk"
  end
end
