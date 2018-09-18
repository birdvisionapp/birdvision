Fabricator(:user) do
  client
  participant_id { sequence(:participant_id) { |i| i } }
  email "user@tw.com"
  mobile_number "1234567890"
  full_name "test user"
  password "password"
  activation_status User::ActivationStatus::ACTIVATED
end