require 'cucumber/rails'
require 'email_spec/cucumber'
require 'capybara-screenshot/cucumber'

DatabaseCleaner.strategy = :transaction
Cucumber::Rails::Database.javascript_strategy = :transaction
ActionController::Base.allow_rescue = false
Capybara.default_selector = :css

Capybara.app_host=(ENV["ENVIRONMENT"]).present? ? "http://#{ENV['ENVIRONMENT']}" : nil

Capybara.javascript_driver = ENV["BROWSER"].present? ? (ENV["REMOTE_MACHINE_IP"].present? ? :bvc_selenium_remote : :bvc_selenium) : :webkit

Capybara.register_driver :bvc_selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => ENV["BROWSER"].to_sym)
end

Capybara.register_driver :bvc_selenium_remote do |app|
  #Replace you machine ip to run it remotely
  #Capybara.app_host = "http://#{your_machine_ip}:3000"
  Capybara::Selenium::Driver.new(app,remote_driver_options)
end

def remote_driver_options
  remote_capabilities =  Selenium::WebDriver::Remote::Capabilities.send(ENV["BROWSER"].to_sym)
  remote_capabilities[:javascript_enabled] = true
  {:browser => :remote, :url => "http://#{ENV['REMOTE_MACHINE_IP']}:4444/wd/hub", :desired_capabilities => remote_capabilities}
end

