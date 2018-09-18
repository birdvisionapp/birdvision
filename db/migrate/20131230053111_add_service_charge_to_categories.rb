class AddServiceChargeToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :service_charge, :decimal, :precision => 20, :scale => 2, :default => 0
  end
end
