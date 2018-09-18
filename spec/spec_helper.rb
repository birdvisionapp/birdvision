ENV["RAILS_ENV"] ||= 'test'

#require 'simplecov'
#SimpleCov.start 'rails' do
#   add_filter ".bundle"
#   minimum_coverage 97.09
#end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require "email_spec"
require "paperclip/matchers"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.infer_base_class_for_anonymous_controllers = false
  config.include Devise::TestHelpers, :type => :controller
  config.include Warden::Test::Helpers, :type => :feature
  config.extend LoginHelper, :type => :controller
  config.include BetterShouldaMatchers, :type => :model
  #config.extend PaperclipHelper, :type => :controller
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  config.include(UserCatalogHelper)
  config.include(CatalogHelper)

  config.order = "random"
  config.fail_fast = ENV["FAST"]

  config.filter_run_excluding :pre_deploy_check => true

  config.use_transactional_fixtures = true
  config.include Paperclip::Shoulda::Matchers

  trap 'TTIN' do
    Thread.list.each do |thread|
      puts "Thread TID-#{thread.object_id.to_s(36)}"
      puts thread.backtrace.join("\n")
    end
  end
end

def with_versioning
  was_enabled = PaperTrail.enabled?
  PaperTrail.enabled = true
  begin
    yield
  ensure
    PaperTrail.enabled = was_enabled
  end
end

def assign_level_club(user_scheme, level_name, club_name)
  user_scheme.assign_attributes(:level => Level.with_scheme_and_level_name(user_scheme.scheme, level_name).first, :club => Club.with_scheme_and_club_name(user_scheme.scheme, club_name).first)
end

def update_level_club(user_scheme, level_name, club_name)
  assign_level_club(user_scheme, level_name, club_name)
  user_scheme.save!
end