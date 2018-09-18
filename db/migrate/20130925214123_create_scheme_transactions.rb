class CreateSchemeTransactions < ActiveRecord::Migration
  def change
    create_table :scheme_transactions do |t|
      t.integer :client_id
      t.integer :user_id
      t.integer :scheme_id
      t.string :action
      t.string :transaction_type
      t.integer :transaction_id
      t.integer :points, :default => 0, :null => false
      t.integer :remaining_points, :default => 0, :null => false
      t.timestamps
    end
    add_index :scheme_transactions, :client_id
    add_index :scheme_transactions, :user_id
    add_index :scheme_transactions, :scheme_id
    add_index :scheme_transactions, :action
    add_index :scheme_transactions, :transaction_type
    add_index :scheme_transactions, :transaction_id
  end
end
