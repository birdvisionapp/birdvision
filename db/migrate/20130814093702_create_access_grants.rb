class CreateAccessGrants < ActiveRecord::Migration
  def change
    create_table :access_grants do |t|
      t.integer :user_id
      t.integer :client_id
      t.string :code
      t.string :access_token
      t.string :refresh_token
      t.datetime :access_token_expires_at
      t.string :state

      t.timestamps
    end

    add_index :access_grants, :user_id
    add_index :access_grants, :client_id
    add_index :access_grants, :code
  end
end
