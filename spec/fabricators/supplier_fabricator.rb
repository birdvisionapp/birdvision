Fabricator(:supplier) do
  name { sequence(:name) { |i| "Supplier - #{i}" } }
  address "Yerwada, Pune MH 411006"
  phone_number "02012345678"
  geographic_reach "Pan India"
  delivery_time "3-5 days"
  payment_terms "15 days"
  supplied_categories "Electronics, Furniture, Home Appliances, Mobiles"
  description "description of fabricated supplier"
  additional_notes "This is a fabricated supplier"
end
