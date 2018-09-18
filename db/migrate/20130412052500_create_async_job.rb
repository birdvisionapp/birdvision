class CreateAsyncJob < ActiveRecord::Migration
  def change
    create_table :async_jobs do |table|
      table.string :job_owner
      table.text :csv_errors, :limit => 4294967295
      table.string :status
      table.timestamps
    end
    add_attachment :async_jobs, :csv
  end
end
