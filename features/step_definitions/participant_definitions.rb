When /^I login as "([^"]*)" for client "([^"]*)"$/ do |user, client_name|
  login("#{client_name.downcase}.#{user.downcase}", "password")
end

Then /^I add "([^"]*)" to a cart with price "([^"]*)"$/ do |item_title, price|
  verify_item_in_catalogue(:title => "#{item_title}", :price_shown => price)
  verify_add_to_cart_from_item_description_page(:title => "#{item_title}", :price_shown => price)
end

Then /^The item "([^"]*)" with price "([^"]*)" should not be shown in catalog page$/ do |item_title, price|
  verify_item_not_in_catalogue(:title => "#{item_title}", :price_shown => price)
end

And /^I redeem "([^"]*)"/ do |title|
  redeem_single_redemption_item(title)
  verify_order_preview(title)
  confirm_order_on_confirmation_page
  verify_order_created(title)
end

Then /^I should be able to redeem order for "([^"]*)"$/ do |title|
  redeem_order_from_cart_page
  verify_order_preview(title)
  confirm_order_on_confirmation_page
  verify_order_created(title)
end

Then /^I should see "([^"]*)" order status as "([^"]*)" in my orders$/ do |item, status|
  verify_order_displayed_to_participant({'Product Description' => item, "quantity" => 1, "status" => status})
end

Then /^I should see the following orders in my orders$/ do |table|
  table.hashes.each { |row|
    verify_order_displayed_to_participant(row)
  }
end

When /^I view scheme "([^"]*)"$/ do |scheme_name|
  view_scheme scheme_name
end

Then /^I view "([^"]*)" club catalog$/ do |club|
  view_catalog club
end

Then /^I should not be able to redeem$/ do
  cannot_redeem
end

Then /^I should be able to redeem$/ do
  can_redeem
end

When /^I should be able to search for "([^"]*)"$/ do |keyword|
  search_for_keyword(keyword)
  verify_search_results_displayed(keyword)
end

Then /^I should see the search results in the left navigation for "([^"]*)"$/ do |keyword|
  verify_navigation_search_results(keyword)
end

When /^I login as (?:operations|fulfilment) manager into the admin app$/ do
  #Being done for smoke
  unless ENV["SMOKE_ADMIN"].present?
    @admin_user ||= Fabricate(:admin_user)
    login_admin_user(@admin_user.username, @admin_user.password)
  else
    login_admin_user(ENV["SMOKE_ADMIN"]|| "admin", ENV["SMOKE_ADMIN_PASSWORD"] || "password")
  end
  open_admin_dashboard
end

When /^I logout$/ do
  logout_user
end