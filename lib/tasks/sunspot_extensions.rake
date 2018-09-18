namespace :sunspot_ext do
  namespace :solr do
    task :stop do
      begin
        Rake::Task['sunspot:solr:stop'].invoke
      rescue
        puts "No sunspot instance running"
      end
    end
    task :start => ["sunspot_ext:solr:stop", "sunspot_ext:solr:kill"] do
      Rake::Task['sunspot:solr:start'].invoke
    end
    task :kill do
      list = `ps aux | grep solr.data`
      real_list = list.split "\n"
      pids = real_list.collect { |line| line.split[1] }
      pids.each { |pid|
        `kill -9 #{pid}` if pid =~ /\d+/
      }
    end
  end
end
