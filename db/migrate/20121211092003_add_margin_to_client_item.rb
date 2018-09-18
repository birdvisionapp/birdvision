class AddMarginToClientItem < ActiveRecord::Migration
  def change
    add_column :client_items, :margin, :integer
  end
end
