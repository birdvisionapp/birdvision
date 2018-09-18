dash_client = Client.create!(:client_name => "Dashing Client", :contact_email => "emerson@mailinator.com", :points_to_rupee_ratio => 2, :code => "dashing")
dash_user = User.create!(:client => dash_client, :participant_id => "user", :email => 'tester@mailinator.com', :password => "password", :password_confirmation => "password", :full_name => "test user", :mobile_number => "1234567890")

image_path = "." + "/public/images/"

5.times do |i|
  scheme = Scheme.new(:name => "Dash Scheme - #{i}", :client_id => dash_client.id,
                      :start_date => i.days.ago, :end_date => (i+1).days.from_now,
                      :redemption_start_date => (i+1).days.from_now, :redemption_end_date => (i+2).days.from_now,
                      :poster => File.new(image_path + 'schemes/big_bang_dhamaka.png'),
                      :hero_image => File.new(image_path + 'schemes/hero_bbd.png'), :single_redemption => false)

  level = Level.create!(:name => "Dash level #{i}")

  level_clubs = rand(3..10).times.collect { |l|
    scheme.level_clubs.build(:level => level, :club => Club.create!(:name => "Dash club - #{l}", :rank=>l+1), :scheme => scheme)
  }
  scheme.save!

  user_club = scheme.clubs[rand(0..(scheme.clubs.size-1))]
  user_scheme = UserScheme.create!(:user_id => dash_user.id, :scheme_id => scheme.id, :level => scheme.levels.first,
                                   :club => user_club, :current_achievements => rand(0..5000))


  targets = scheme.clubs.collect.with_index { |club, club_index|
    Target.create!(:club => club, :start => club_index *1000, :user_scheme => user_scheme)
  }


  rand(1..10).times.collect { |u|
    random_user = User.create!(:client => dash_client, :participant_id => "dash_user_#{i}#{u}", :email => "dash_#{u}@mailinator.com",
                               :password => "password", :password_confirmation => "password", :full_name => "dash user #{u}",
                               :mobile_number => "1234567890")

    UserScheme.create!(:user_id => random_user.id, :scheme_id => scheme.id, :level => scheme.levels.first,
                       :club => user_club, :current_achievements => rand(0..5000))
  }
end