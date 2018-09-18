class CreateRegionalManagersUsers < ActiveRecord::Migration

  def change
    create_table :regional_managers_users, :id => false, :force => true do |t|
      t.belongs_to :regional_manager
      t.belongs_to :user
    end
    add_index :regional_managers_users, :regional_manager_id
    add_index :regional_managers_users, :user_id
  end

end
