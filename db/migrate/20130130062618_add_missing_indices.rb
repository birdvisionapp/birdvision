class AddMissingIndices < ActiveRecord::Migration
  def change
    add_index(:schemes, :slug)
    add_index(:client_items, :client_price)
    add_index(:client_items, :deleted)
  end
end
