Fabricator(:draft_item) do
  supplier { Fabricate(:supplier) }
  title "Samsung s2"
  mrp 32000
  channel_price 30000
  model_no "S123"
  description "Smart Phone"
  specification "Awesome Phone"
  listing_id "L12"
  available_till_date  Date.tomorrow
  category { Fabricate(:category) }
end
