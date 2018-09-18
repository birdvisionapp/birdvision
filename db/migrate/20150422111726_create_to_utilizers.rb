class CreateToUtilizers < ActiveRecord::Migration
  def change
    create_table :to_utilizers do |t|
      t.belongs_to :to_applicable_user
      t.string :status
      t.string :result
      t.timestamps
    end
  end
end
