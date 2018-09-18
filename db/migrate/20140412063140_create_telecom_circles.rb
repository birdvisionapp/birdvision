class CreateTelecomCircles < ActiveRecord::Migration
  def change
    create_table :telecom_circles do |t|
      t.string :code, :limit => 6
      t.text :description, :limit => 3000

      t.timestamps
    end
  end
end
