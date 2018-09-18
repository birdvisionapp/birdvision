class AddSlabsToReseller < ActiveRecord::Migration
  def change
    create_table :slabs do |t|
      t.float :slab_limit
      t.float :commission_percentage
      t.references :reseller
    end
    add_foreign_key "slabs", "resellers", :name => "slabs_reseller_id_fk"
  end
end
