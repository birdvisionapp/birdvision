class CreateClientItems < ActiveRecord::Migration
  def change
    create_table :client_items do |t|
      t.references :item, :null => false
      t.references :client, :null => false
      t.integer :client_price
    end
  end
end
