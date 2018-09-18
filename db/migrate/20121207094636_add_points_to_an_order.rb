class AddPointsToAnOrder < ActiveRecord::Migration
  def change
    add_column :orders, :points, :integer
  end
end
