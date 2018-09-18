class AssociateSchemeUsers < ActiveRecord::Migration
  def change
    create_table :schemes_users, :id => false do |t|
      t.integer :scheme_id
      t.integer :user_id
    end

    remove_column :users, :client_id

    add_index :schemes_users, [:scheme_id, :user_id], :unique => true
  end
end
