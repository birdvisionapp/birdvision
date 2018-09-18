class AddAdminUserToAsyncJobs < ActiveRecord::Migration
  def change
    add_column :async_jobs, :admin_user_id, :integer
    add_index :async_jobs, :admin_user_id
  end
end
