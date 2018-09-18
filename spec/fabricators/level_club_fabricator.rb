Fabricator(:level_club) do
  transient :level_name, :club_name
  level { |attrs| Fabricate(:level, :name => (attrs[:level_name] || "Level1")) }
  club { |attrs| Fabricate(:club, :name => (attrs[:club_name] || "Platinum")) }
  scheme
end