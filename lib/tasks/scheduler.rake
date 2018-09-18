desc "This task is called by the Heroku scheduler add-on"
task :generate_invoice => :environment do
  if Date.today.day == 25
    Rails.logger.info "CRON START - Generating Client Invoices Time: #{Time.now}"
    Client.non_msp.generate_invoices(Date.today)
    Rails.logger.info "DATE: #{Date.today}"
    Rails.logger.info "CRON END - Generated Client Invoices Time: #{Time.now}"
  end
end

task :generate_points_statement => :environment do
  Rails.logger.info "CRON START - Generating Client Points Statement Time: #{Time.now}"
  Client.non_msp.generate_statements(Date.yesterday)
  Rails.logger.info "DATE: #{Date.yesterday}"
  Rails.logger.info "CRON END - Generated Client Points Statement Time: #{Time.now}"
end

task :low_balance_reminder => :environment do
  Rails.logger.info "CRON START - Sending Low Balance Reminder Time: #{Time.now}"
  Client.non_msp.low_balance_reminder
  Rails.logger.info "CRON END - Sent Low Balance Reminder Time: #{Time.now}"
end

task :notify_retailer_balance => :environment do
  Rails.logger.info "CRON START - Sending Retailer Balance Notification Time: #{Time.now}"
  User.notify_retailer_balance
  Rails.logger.info "CRON END - Sent Retailer Balance Notification Time: #{Time.now}"
end

task :notify_daily_status => :environment do
  Rails.logger.info "CRON START - Sending Daily Status to Representative Time: #{Time.now}"
  Representative.notify_daily_status
  Rails.logger.info "CRON END - Sent Daily Status to Representative Time: #{Time.now}"
end
