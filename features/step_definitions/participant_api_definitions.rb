require 'spec_helper'

When /^I send a POST request to "([^\"]*)" with:$/ do |url, body|
  header 'client_id', 'abc123'
  header 'client_secret', 'abcdef12345'
  post url, body
end

When /^I send a POST request to "([^\"]*)" with valid headers and with:$/ do |url, body|
  client = Fabricate(:client_allow_sso)
  header 'client_id', client.client_key
  header 'client_secret', client.client_secret
  post url, body
end

Then /^I should receive the following JSON response:$/ do |expected_json|
  expected_json = JSON.parse(expected_json)
  response_json = JSON.parse(last_response.body)
  response_json.should == expected_json
end

Given /^I send and accept JSON$/ do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
end

Then /^the response should be "([^\"]*)"$/ do |status|
  last_response.status.should == status.to_i
end

Given /^I send valid client headers$/ do
  client = Fabricate(:client_allow_sso)
  header 'client_id', client.client_key
  header 'client_secret', client.client_secret
end

When /^I send a GET request to "([^\"]*)" with invalid participant_id$/ do |url|
  client = Fabricate(:client_allow_sso)
  header 'client_id', client.client_key
  header 'client_secret', client.client_secret
  header 'participant_id', 'testuser1'
  get url
end

When /^I send a POST request to "([^\"]*)" with invalid participant_id$/ do |url|
  client = Fabricate(:client_allow_sso)
  header 'client_id', client.client_key
  header 'client_secret', client.client_secret
  header 'participant_id', 'testuser1'
  post url
end

When /^I send a GET request to "([^\"]*)" with valid participant_id and status "([^"]*)"$/ do |url, status|
  client = Fabricate(:client_allow_sso)
  user = Fabricate(:user, :status => status, :client => client)
  header 'client_id', client.client_key
  header 'client_secret', client.client_secret
  header 'participant_id', user.participant_id
  if status == 'active'
    test_scheme = Fabricate(:scheme, :client => client, :name => "BBD test", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today + 45.days, :single_redemption => false)
    Fabricate(:user_scheme, :user => user, :scheme => test_scheme, :total_points => 2000, :redeemed_points => 300)
  end
  get url
end

When /^I send a POST request to "([^\"]*)" with valid participant_id and status "([^"]*)"$/ do |url, status, body|
  client = Fabricate(:client_allow_sso)
  user = Fabricate(:user, :status => status, :client => client)
  header 'client_id', client.client_key
  header 'client_secret', client.client_secret
  header 'participant_id', user.participant_id
  post url, body
end