When /^I login as reseller "([^"]*)" into the admin app$/ do |reseller_name|
  reseller = Reseller.find_by_name(reseller_name) # as username is generated
  login_admin_user(reseller.admin_user.username, "password")
end

When /^I login as client manager "([^"]*)" into the admin app$/ do |client_manager_name|
  client_manager = ClientManager.find_by_name(client_manager_name) # as username is generated
  login_admin_user(client_manager.admin_user.username, "password")
end

When /^I login as smoke reseller into the admin app$/ do
  login_admin_user(ENV["SMOKE_RESELLER_USER"] || "bvc.reseller", ENV["SMOKE_RESELLER_PASSWORD"] || "password")
end

When /^I login as smoke client manager into the admin app$/ do
  login_admin_user(ENV["CLIENT_MANAGER"] || "bvc.client_manager", ENV["CLIENT_MANAGER_PASSWORD"] || "password")
end

