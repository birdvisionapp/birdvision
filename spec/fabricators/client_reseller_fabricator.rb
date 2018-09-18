Fabricator(:client_reseller) do
  client
  reseller
  payout_start_date Date.today
  finders_fee 10_000
  assigned true
end