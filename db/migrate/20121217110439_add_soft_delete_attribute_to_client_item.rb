class AddSoftDeleteAttributeToClientItem < ActiveRecord::Migration
  def change
    add_column :client_items, :deleted, :boolean, :default => false
  end
end
