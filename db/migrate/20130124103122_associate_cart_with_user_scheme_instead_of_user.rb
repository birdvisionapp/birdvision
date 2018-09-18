class AssociateCartWithUserSchemeInsteadOfUser < ActiveRecord::Migration
  def change
    remove_foreign_key(:carts, :user)
    remove_column :carts, :user_id

    change_table :carts do |t|
      t.references :user_scheme
    end
  end
end
