class ChangeUpdatedAtFromProductCodeLinks < ActiveRecord::Migration
  def up
    remove_index :product_code_links, :column => [:linkable_type, :linkable_id]
    remove_column :product_code_links, :updated_at
    add_index :product_code_links, [:linkable_type, :linkable_id]
  end

  def down
    add_column :product_code_links, :updated_at, :datetime
  end
end
