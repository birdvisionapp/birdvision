require 'spec_helper'
require 'capybara-screenshot/rspec'

RSpec.configure do |config|
  config.include Warden::Test::Helpers, :type => :request
  config.include HelperMethods, :type => :request
  #config.extend PaperclipHelper, :type => :request
end