source 'http://rubygems.org'
ruby "1.9.3p551"
gem 'rails', '3.2.11'

gem 'rb-readline'
gem 'haml'
gem 'devise', '2.2.4'
gem 'ancestry'
gem 'sunspot_rails'
gem 'inherited_resources'
gem 'has_scope'
gem 'ransack'
gem 'iso_country_codes'
gem 'kaminari'
gem 'paperclip'
gem 'ckeditor'
gem "state_machine", "~> 1.1.2"
gem 'jquery-rails'
gem 'underscore-rails'
gem 'paper_trail'
gem 'exotel'
gem 'httparty'

gem 'rake', '10.0.4'
gem 'foreigner'
gem 'foreman'
gem 'newrelic_rpm'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'faker' # Used only for perf
gem 'delayed_job_active_record'
gem 'cancan'
gem 'sendgrid'

gem 'mysql2', '~> 0.3.20'

# To provide Single Sign-On to the clients
gem 'omniauth'

# To generate One Time Passwords
gem 'active_model_otp'

# To resolve heroku request time out
gem 'rack-timeout'

gem 'heroku'

# To generate dynamic form fields
gem 'nested_form'

# To generate PDF
gem 'prawn'

# To convert currency to words
gem 'rupees'

# To select options searchable
gem 'select2-rails'

# Ruby library for rendering safe templates which cannot affect the security of the server they are rendered on.
gem 'liquid'

# To generate the coupon code labels for print
gem 'prawn-labels'

# To void Potential security vulnerability in Ruby and YAML parsing
gem 'psych', '~> 2.0.5'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'bootstrap-sass'
  gem 'bootstrap-datepicker-rails'
  gem 'uglifier', '>= 1.0.3'
  gem "asset_sync"
  gem "turbo-sprockets-rails3"
  gem 'jquery-minicolors-rails'
end

gem 'coffee-rails', '~> 3.2.1'

gem 'jquery-validation-rails'
gem 'time_diff'

group :test, :development do
  gem 'heroku_san'
  gem 'jasmine-rails'
  gem 'fuubar'
  gem 'fabrication'
  gem 'rspec-rails'
  gem 'thin'
  gem 'better_errors'
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'sunspot_solr'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'simplecov', :require => false
  gem 'capybara-screenshot'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem "chromedriver-helper"
  # gem "capybara-webkit"
  gem 'email_spec'
  gem 'timecop'
end

group :development do
  gem "data-anonymization"
end

group :production do
  gem 'pg'
  gem 'unicorn'
  gem 'aws-sdk'
  gem 'rails_12factor'
end