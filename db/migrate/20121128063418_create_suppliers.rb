class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :phone_number
      t.text :address
      t.text :description
      t.string :supplied_categories
      t.string :geographic_reach
      t.text :additional_notes

      t.timestamps
    end
  end
end
