class CreateThresholds < ActiveRecord::Migration
  def change
    create_table :thresholds do |t|
      t.integer :low
      t.integer :medium
      t.integer :high
      t.string :low_color
      t.string :medium_color
      t.string :high_color
      t.belongs_to :client_manager

      t.timestamps
    end
  end
end
