class AddCircleIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :telecom_circle_id, :integer
    add_index :users, :telecom_circle_id
  end
end
