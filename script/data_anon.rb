## Steps to anonymize data
## 1. dump of the data from the source db (e.g. Production) . This would generate a drop and recreate for tables.(Exactly what we want)
##      mysqldump -u USER -pPASSWORD -h HOST  SOURCE_DB_NAME --single-transaction > mysqldump.sql
## 2. import it locally using `mysql -u #{user} -p#{password} -h #{host} #{database} < mysqldump.sql`
## 3. run the script to anonymize data.
##      be ruby script/data_anon.rb

require 'data-anonymization'
require 'delayed_job'

database = ENV["TARGET_DB"] || "birdvision" # DATA WILL BE OVERWRITTEN
host = ENV["TARGET_HOST"] || "127.0.0.1" # DATA WILL BE OVERWRITTEN
user = ENV["TARGET_USER"] || "root" # DATA WILL BE OVERWRITTEN
password = ENV["TARGET_PASSWORD"] || "p@ssw0rd" # DATA WILL BE OVERWRITTEN
DataAnon::Utils::Logging.logger.level = Logger::INFO


database 'bvc' do
  strategy DataAnon::Strategy::Blacklist
  source_db :adapter => 'mysql2', :database => database, :password => password, :host => host, :user => user

  table 'users' do
    primary_key "id"
    anonymize('full_name')
    anonymize('email') { |field| "bvc.#{field.ar_record.username}@mailinator.com" }
    anonymize('mobile_number') { |field| nil }
    anonymize('reset_password_token') { |field| field.ar_record.reset_password_sent_at.nil? ? nil : FieldStrategy::RandomString.new.anonymize(field) }
  end

  table 'admin_users' do
    primary_key 'id'
    anonymize('username') { |field| "test.#{field.ar_record.username}" }
  end

  table 'clients' do
    primary_key "id"
    anonymize('contact_phone_number') { |field| nil }
    anonymize('contact_email').using FieldStrategy::RandomMailinatorEmail.new
    anonymize('domain_name') { |field| "test.bvcrewards.com" }
  end

  table 'suppliers' do
    primary_key "id"
    anonymize('phone_number') { |field| nil }
  end

  table 'delayed_jobs' do
    primary_key "id"
    anonymize('handler') { |field| Delayed::PerformableMethod.new("fake job", :present?, []).to_yaml }
    anonymize('failed_at') { |field| nil }
  end

  table "orders" do
    primary_key "id"
    anonymize('address_phone') { |field| nil }
    anonymize('address_name')
    anonymize('address_body')
    anonymize('address_landmark')
  end

  table "order_items" do
    primary_key "id"
    anonymize("shipping_agent") {"ACME"}
    anonymize("shipping_code").using FieldStrategy::RandomString.new
  end
end

