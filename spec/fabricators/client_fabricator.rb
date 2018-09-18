Fabricator(:client) do
  client_name { sequence(:client_name) { |i| "client name #{i}" } }
  contact_email "client@client.com"
  contact_phone_number 1234567891
  points_to_rupee_ratio 10
  contact_name "contact name"
  description "description"
  notes "fabricated client"
  code { |attrs| attrs[:client_name].parameterize }
  after_create { |client|
    Fabricate(:client_catalog, :client => client)
  }
end

Fabricator(:client_allow_sso, :from => :client) do
  allow_sso true
  client_key { SecureRandom.hex(8) }
  client_secret { SecureRandom.hex }
  client_url "http://test.client.com"
end

Fabricator(:client_allow_otp, :from => :client) do
  allow_otp true
  allow_otp_email true
  allow_otp_mobile true
  otp_code_expiration 100
end