class IncreaseDelayedJobHandlerSize < ActiveRecord::Migration
  def change
    change_column :delayed_jobs, :handler, :text, :limit => 2**24 - 1 #equivalent of MEDIUMTEXT in mysql2
  end
end
