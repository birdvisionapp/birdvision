class AssociateSupplierWithDraftItems < ActiveRecord::Migration
  def up
    change_table :draft_items do |t|
      t.remove :supplier_name #TODO KD fix the migration warning : "Passing array to remove_columns is deprecated, please use multiple arguments, like: remove_columns(:posts, :foo, :bar)"
      t.references :supplier
    end
  end

  def down
    change_table :draft_items do |t|
      t.remove :supplier_id
      t.string :supplier_name
    end
  end
end
