Fabricator(:item_supplier) do
  item
  supplier
  mrp 5_000
  channel_price 8_000
  is_preferred false
  available_till_date Date.tomorrow
  available_quantity 100
  geographic_reach "Pan India"
end
