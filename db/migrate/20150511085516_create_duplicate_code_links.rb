class CreateDuplicateCodeLinks < ActiveRecord::Migration
  def change
    create_table :duplicate_code_links do |t|
      t.belongs_to :unique_item_code
      t.string  :code
      t.integer :user_id_1 
      t.datetime :used_at_1
      t.integer :user_id_2
      t.datetime :used_at_2
      t.integer :used_count,  :default => 2, :null => false
      t.timestamps
    end
  end
end
