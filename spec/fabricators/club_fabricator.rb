Fabricator(:club) do
  name 'Platinum'
  rank { sequence(:rank)}
end