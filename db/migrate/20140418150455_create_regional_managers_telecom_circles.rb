class CreateRegionalManagersTelecomCircles < ActiveRecord::Migration
  def change
    create_table :regional_managers_telecom_circles do |t|
      t.belongs_to :regional_manager
      t.belongs_to :telecom_circle
    end
    add_index :regional_managers_telecom_circles, :regional_manager_id
    add_index :regional_managers_telecom_circles, :telecom_circle_id
  end
end
