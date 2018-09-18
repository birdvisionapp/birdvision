# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Birdvision::Application.initialize!

SERVICE_TAX = App::Config.settings[:service_tax].to_f
APP_TITLE = App::Config.settings[:app_title]