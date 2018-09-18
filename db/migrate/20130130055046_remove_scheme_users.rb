class RemoveSchemeUsers < ActiveRecord::Migration
  def up
    drop_table :schemes_users
  end
end
