class CreateScheme < ActiveRecord::Migration
  def change
    create_table :schemes do |t|
      t.references :client, :null => false
      t.string :name, :null => false
      t.attachment :poster
      t.date :redemption_start_date
      t.date :redemption_end_date
      t.date :start_date
      t.date :end_date
      t.boolean :point_expiry
      t.boolean :catalog_expiry
      t.timestamps
    end
  end
end