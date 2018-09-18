class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.references :user, :null => false, :unique => true
      t.timestamps
    end
  end
end
