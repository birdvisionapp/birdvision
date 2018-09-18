class AddDeliveryChargesToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :delivery_charges, :decimal, :precision => 20, :scale => 2, :default => 0
  end
end
