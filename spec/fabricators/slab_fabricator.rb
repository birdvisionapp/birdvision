Fabricator(:slab) do
  lower_limit { sequence(:lower_limit) { |i| i*1000 } }
  payout_percentage { sequence(:payout_percentage) { |i| i } }
end

