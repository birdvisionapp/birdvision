ENV["RAILS_ENV"] ||= 'test'

require 'capybara/rspec'

Capybara.configure do |config|
  config.default_driver = :webkit
end

Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |scenario|
  "screenshot-#{scenario.description.gsub(' ', '_')}"
end

Thread.main[:activerecord_connection] = ActiveRecord::Base.retrieve_connection

def (ActiveRecord::Base).connection
  Thread.main[:activerecord_connection]
end

module HelperMethods

  def login_user(user)
    visit(new_user_session_path)

    fill_in('user_username', :with => user.username)
    fill_in('user_password', :with => user.password)
    click_button("Sign in")
  end

end
