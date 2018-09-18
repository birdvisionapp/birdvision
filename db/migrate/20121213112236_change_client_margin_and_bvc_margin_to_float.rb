class ChangeClientMarginAndBvcMarginToFloat < ActiveRecord::Migration
  def change
    change_column :items, :margin, :float
    change_column :client_items, :margin, :float
  end
end
