When /^I send a GET request to "([^\"]*)" with "([^\"]*)" client_id and with "([^\"]*)" redirect_uri$/ do |url, type, rtype|
  client_id, redirect_uri = 'test123', ''
  if type == 'valid'
    client = Fabricate(:client_allow_sso)
    client_id = client.client_key
  end
  redirect_uri = 'www.test.domain.com' if rtype == 'valid'
  get url, {client_id: client_id, redirect_uri: redirect_uri}
end

When /^I send a GET request to "([^\"]*)" with "([^\"]*)" participant_id$/ do |url, type|
  client = Fabricate(:client_allow_sso)
  client_id, redirect_uri, participant_id = client.client_key, 'www.test.domain.com', 't1'
  if ['valid', 'inactive'].include?(type)
    status = (type == 'inactive') ? User::Status::INACTIVE : User::Status::ACTIVE
    user = Fabricate(:user, :status => status, :participant_id => 'test1', :client => client)
    participant_id = user.participant_id
  end
  get url, {client_id: client_id, redirect_uri: redirect_uri, scope: {participant_id: participant_id}}
end


Then /^I should be redirect to "([^\"]*)" page$/ do |url|
  visit url
end


When /^I send a GET request to "([^\"]*)" with "([^\"]*)" client_id and client_secret$/ do |url, type|
  client_id, client_secret = 'test123', 'test123456'
  if type == 'valid'
    client = Fabricate(:client_allow_sso)
    client_id, client_secret = client.client_key, client.client_secret
  end
  get url, {client_id: client_id, client_secret: client_secret}
end