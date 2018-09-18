Given /^I create the following suppliers$/ do |table|
  table.hashes.each_with_index do |row, index|
    create_new_supplier(row, index)
  end
end

And /^I create the following resellers/ do |table|
  table.hashes.each do |row|
    create_new_reseller(row)
  end
end

And /^I create the following client managers/ do |table|
  table.hashes.each do |row|
    create_new_client_manager(row)
  end
end

And /^I assign "([^"]*)" to "([^"]*)" with "([^"]*)" finders fee and following slabs$/ do |reseller_name, client_name, finders_fee, table|
  assign_reseller_to_client reseller_name, client_name, finders_fee, table
end

Given /^I create the following categories$/ do |table|
  table.hashes.each do |row|
    create_new_category(row)
  end

end

Given /^I login as admin$/ do
  user = Fabricate(:admin_user)
  login_with(user)
end

When /^I upload draft items from "([^"]*)" file for supplier "([^"]*)"$/ do |file_name, supplier|
  upload_draft_item file_name, supplier
end

When /^I publish the draft item with title "([^"]*)" with category "([^"]*)"$/ do |draft_item, category|
  publish_draft_item draft_item, category
end

Then /^The following items should be shown on catalog$/ do |table|
  table.hashes.each do |row|
    verify_item_in_catalogue(:title => row["item_name"], :price_shown => row["price"])
  end
end

Then /^"([^"]*)" should be shown on catalog without price$/ do |item|
  item_title_on_catalogue_page_displayed?(item)
end

Then /^Only applicable categories should be shown on catalog page$/ do |table|
  table.hashes.each do |row|
    category_displayed_on_catalog_page row["title"]
  end
end
When /^I add base price "([^"]*)" for item "([^"]*)"$/ do |bvc_price, draft_item|
  add_bvc_price bvc_price, draft_item
end

When /^I associate following items with "([^"]*)" catalog for "([^"]*)" of "([^"]*)"$/ do |level_club, scheme, client, table|
  level, club = level_club.split("-")
  table.hashes.each do |row|
    add_item_to_scheme_catalog(scheme, client, row["item_name"])
    add_to_level_club_catalog(client, scheme, level, club, row["item_name"])
  end
end

When /^I add following items to "([^"]*)" client catalog$/ do |client, table|
  table.hashes.each do |row|
    add_items_to_client_catalog(client, row["item_name"])
    assign_client_price_to_the_item(client, row["item_name"], row["client_price"])
  end
end
When /^I remove "([^"]*)" from client catalog of "([^"]*)"$/ do |client_item, client|
  remove_items_from_client_catalog(client, client_item)
end

When /I add following items to "([^"]*)" scheme catalog for "([^"]*)"/ do |scheme, client, table|
  table.hashes.each do |row|
    add_item_to_scheme_catalog(scheme, client, row["item_name"])
  end
end

When /^I add the following clients$/ do |table|
  create_client_from_given_data table
end

When /^I create the following schemes$/ do |table|
  table.hashes.each do |row|
    create_scheme row
  end
end

When /^I add participants for the scheme "([^"]*)" of "([^"]*)"$/ do |scheme_name, client_name|
  upload_users_for "users.csv", scheme_name, client_name
end

When /^I add participants for the point-based scheme "([^"]*)" of "([^"]*)"$/ do |scheme_name, client_name|
  upload_users_for "point_based_users.csv", scheme_name, client_name
end

When /^participant activates account and logs out$/ do
  set_password_of_participant
  logout_user
end

When /^I activate my admin account and log out$/ do
  set_password_of_admin
  logout_user
end

When /^I change the status of order for "([^"]*)" to "([^"]*)"$/ do |item, status|
  change_order_status_to item, status
end

When /^I activate participant "([^"]*)" account$/ do |user_id|
  activate_participant user_id
end

When /^I inactive participant "([^"]*)" account$/ do |user_id|
  inactive_participant user_id
end

When /^I active participant "([^"]*)" account$/ do |user_id|
  active_participant user_id
end

Then /^I should see the following orders for "([^"]*)" and scheme "([^"]*)"$/ do |client, scheme, table|
  #verify_client_present(client_name)
  table.hashes.each { |row|
    verify_order_present(client, row['item'], row['status'], row['price'], scheme)
  }
  navigate_to_dashboard
end

Then /^I should see the client "([^"]*)"$/ do |client_name|
  navigate_to_clients_dashboard
  verify_client_present(client_name)
end

Then /^I should see the following schemes$/ do |table|
  table.hashes.each { |row|
    verify_scheme_present(row['scheme_name'])
  }
  navigate_to_dashboard
end

Then /^I should be able to see the following schemes$/ do |table|
  navigate_to_schemes_dashboard
  table.hashes.each { |row|
    verify_scheme_visible(row['scheme_name'])
  }
end

Then /^I should see following infographics on the dashboard$/ do |table|
  table.hashes.each { |row|
    verify_dashboard_contents(row)
  }
end

Then /^I should see the following participants for "([^"]*)" and scheme "([^"]*)"$/ do |client, scheme, table|
  #verify_client_present(client_name)
  table.hashes.each { |row|
    verify_participant_present(row['participant'], client, scheme, row['points_redeemed'])
  }
  navigate_to_dashboard
end

Then /^I should see the following participants for "([^"]*)"$/ do |client, table|
  navigate_to_participants_dashboard
  table.hashes.each { |row|
    verify_participant_listed(row['participant'], client)
  }

end

Then /^I should see the following client items in "([^"]*)" client catalog$/ do |client, table|
  navigate_to_catalog_dashboard(client)
  table.hashes.each { |row|
    verify_item_in_client_catalog(client, row)
  }
end

Then /^I should see the following client items in scheme catalog of "([^"]*)" of "([^"]*)"$/ do |scheme, client, table|
  navigate_to_scheme_catalog_of(scheme)
  table.hashes.each { |row|
    verify_scheme_catalog_visible(row)
  }
end

When /^I should be able to view "([^"]*)" order for "([^"]*)" in admin dashboard$/ do |item, user|
  verify_order_present_in_admin_dashboard(item, user)
end

When /^I should be able to view the "([^"]*)" order for "([^"]*)" in reseller dashboard for "([^"]*)"$/ do |item, user, client_name|
  verify_order_present_in_reseller_dashboard(item, client_name, user)
end



