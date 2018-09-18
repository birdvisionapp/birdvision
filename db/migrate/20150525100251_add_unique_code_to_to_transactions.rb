class AddUniqueCodeToToTransactions < ActiveRecord::Migration
  def change
    add_column :to_transactions, :unique_code, :string
  end
end