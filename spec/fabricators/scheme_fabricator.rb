Fabricator(:scheme) do
  client
  name "Scheme"
  poster File.new("#{Rails.root}/spec/fixtures/table.jpg")
  hero_image File.new("#{Rails.root}/spec/fixtures/hero_bbd.png")
  start_date Date.today - 20.days
  end_date Date.today - 10.days
  redemption_start_date Date.yesterday
  redemption_end_date Date.today + 10.days
  single_redemption false
  transient :levels, :clubs
  after_build { |scheme, attrs|
    scheme.create_level_clubs(attrs[:levels] || %w(level1), attrs[:clubs] || %w(platinum))
  }
end

Fabricator(:scheme_3x3, :from => :scheme) do
  transient :levels, :clubs
  after_build { |scheme, attrs|
    scheme.level_clubs = []
    scheme.create_level_clubs(attrs[:levels] || %w(level1 level2 level3), attrs[:clubs] || %w(platinum gold silver))
  }
end

Fabricator(:expired_scheme, :from => :scheme) do
  start_date Date.today - 20.days
  end_date Date.today - 10.days
  redemption_start_date Date.today - 9.days
  redemption_end_date Date.today - 2.days
end

Fabricator(:not_yet_started_scheme, :from => :scheme) do
  start_date Date.today + 10.days
  end_date Date.today + 20.days
  redemption_start_date Date.today + 1.month
  redemption_end_date Date.today + 1.month + 15.days
end


Fabricator(:future_scheme, :from => :scheme) do
  start_date Date.today
  end_date Date.today + 10.days
  redemption_start_date Date.today + 11.days
  redemption_end_date Date.today + 20.days
end

Fabricator(:single_redemption_scheme, :from => :scheme) do
  single_redemption true
  client
end