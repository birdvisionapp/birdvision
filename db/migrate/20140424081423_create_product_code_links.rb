class CreateProductCodeLinks < ActiveRecord::Migration
  def change
    create_table :product_code_links do |t|
      t.integer :unique_item_code_id
      t.string :linkable_type, :limit => 16
      t.integer :linkable_id

      t.timestamps
    end
    add_index :product_code_links, :unique_item_code_id
    add_index :product_code_links, [:linkable_type, :linkable_id]
  end
end
