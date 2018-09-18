require 'net/http'


namespace :cleardb do

  desc "Creates a backup on cleardb"
  task :backup => :environment do
    cleardb = ClearDB.new_from_env

    puts "checking for active jobs"
    wait_for_active_jobs(cleardb)

    last_backup_time = cleardb.latest_backup_time
    wait "last backup was made at #{last_backup_time}"

    cleardb.queue_backup
    wait "backup request queued..."
    wait_for_active_jobs(cleardb)

    attempts = 0
    until cleardb.has_backup_after? last_backup_time
      wait "Backup in progress, waiting for it to complete..."
      raise "Too many attempts, Please check the backup manually" if (attempts+=1) > 5
    end

    wait "Backup successful, fetching the lastest backup info"
    puts cleardb.list_backups.first
  end

  desc "Check the database size"
  task :database_size => :environment do
    puts ClearDB.new_from_env.database_size
  end

  desc "Check the database size"
  task :dataset_size => :environment do
    puts ClearDB.new_from_env.dataset_size
  end

  desc "Lists all the available backups"
  task :list_backups => :environment do
    puts ClearDB.new_from_env.list_backups
  end

  desc "prints the latest backup time"
  task :latest_backup_time => :environment do
    puts ClearDB.new_from_env.latest_backup_time
  end

  def wait_for_active_jobs(cleardb)
    wait "There are active jobs, waiting 30 sec before retry..." until cleardb.has_no_active_jobs?
  end

  def wait(message="waiting...")
    puts message
    sleep 30
  end
end

class ClearDB
  def initialize(schema_name, api_key)
    @schema_name = schema_name
    @api_key = api_key
  end

  def self.new_from_env()
    cleardb_db_name = ENV["CLEARDB_DB_NAME"]
    cleardb_api_key = ENV["CLEARDB_API_KEY"]

    raise "set CLEARDB_DB_NAME and CLEARDB_API_KEY environment variables" if cleardb_api_key.nil? || cleardb_db_name.nil?

    ClearDB.new(cleardb_db_name, cleardb_api_key)
  end

  def invoke(action)
    endpoint = "http://www.cleardb.com/service/1.0/api?action=#{action}&schema_name=#{@schema_name}&api_key=#{@api_key}"
    result = Net::HTTP.get(URI.parse(endpoint))
    response_json = ActiveSupport::JSON.decode(result.to_s)
    raise "response not successful #{response_json.to_s}" unless response_json["result"] == "success"
    response_json["response"]
  end

  def has_no_active_jobs?
    invoke("getJobs").size() == 0
  end

  def queue_backup
    response = invoke("backupDatabase")
    raise "unexpected response: #{response.to_s}" unless response.to_s == "Backup job has been queued."
  end

  def list_backups
    invoke("getBackups")
  end

  def database_size
    invoke("getDatabaseSize")
  end

  def dataset_size
    invoke("getDatasetSize")
  end

  def latest_backup_time
    list_backups.collect { |backup| Time.parse(backup['create_ts'] + " UTC") }.max
  end

  def has_backup_after?(time)
    latest_backup_time > time
  end
end