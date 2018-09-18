# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require_relative 'smoke_seeds'

def associate_targets_and_achievements(attrs, level_name, club_name, target_attrs={})
  scheme = Scheme.find(attrs[:scheme_id])
  attrs.merge!(:level => Level.with_scheme_and_level_name(scheme, level_name).first) if level_name.present?
  attrs.merge!(:club => Club.with_scheme_and_club_name(scheme, club_name).first) if club_name.present?
  user_scheme = UserScheme.create!(attrs)

  target_attrs.each do |name, start|
    Target.create!(:club => Club.with_scheme_and_club_name(user_scheme.scheme, name).first, :start => start, :user_scheme => user_scheme)
  end
end

image_path = "." + "/public/images/"
client_emerson = Client.create!(:client_name => "Emerson", :contact_email => "emerson@mailinator.com", :points_to_rupee_ratio => 2, :code => "emerson", :address => "test address")
emerson_catalog = client_emerson.create_client_catalog
emerson_user_role = client_emerson.user_roles.create!(:name => "Default Role")
client_emerson.save!

emerson_active_scheme = Scheme.new(:name => 'Big Bang Dhamaka', :client_id => client_emerson.id, :start_date => Date.today - 30.days,
                                   :end_date => Date.yesterday, :redemption_start_date => Date.today, :redemption_end_date => Date.today + 30.days,
                                   :poster => File.new(image_path + 'schemes/big_bang_dhamaka.png'),
                                   :hero_image => File.new(image_path + 'schemes/hero_bbd.png'), :single_redemption => false)
emerson_active_scheme.create_level_clubs(%w(level1), %w(all))
emerson_active_scheme.save!

emerson_past_scheme = Scheme.new(:name => 'Big Bang Dhamaka - Past', :client_id => client_emerson.id,
                                 :start_date => Date.today - 30.days, :end_date => Date.today - 15.days,
                                 :redemption_start_date => Date.today - 15.days, :redemption_end_date => Date.today - 3.days,
                                 :poster => File.new(image_path + 'schemes/big_bang_dhamaka.png'),
                                 :hero_image => File.new(image_path + 'schemes/hero_bbd.png'), :single_redemption => false)
emerson_past_scheme.create_level_clubs(%w(level1), %w(all))
emerson_past_scheme.save!

emerson_future_scheme = Scheme.new(:name => 'Big Bang Dhamaka - Future', :client_id => client_emerson.id, :start_date => Date.today - 30.days,
                                   :end_date => Date.tomorrow, :redemption_start_date => Date.today + 40.days, :redemption_end_date => Date.today + 60.days,
                                   :poster => File.new(image_path + 'schemes/big_bang_dhamaka.png'), :hero_image => File.new(image_path + 'schemes/hero_bbd.png'), :single_redemption => false)

emerson_future_scheme.create_level_clubs(%w(level1), %w(all))
emerson_future_scheme.save!


emerson_single_redemption_scheme = Scheme.new(:name => 'Single redemption Scheme', :client_id => client_emerson.id, :start_date => Date.today - 30.days,
                                              :end_date => Date.yesterday, :redemption_start_date => Date.today, :redemption_end_date => Date.today + 60.days,
                                              :poster => File.new(image_path + 'schemes/big_bang_dhamaka.png'), :single_redemption => true)
emerson_single_redemption_scheme.create_level_clubs(%w(level1 level2 level3), %w(platinum gold silver))
emerson_single_redemption_scheme.save!

user1 = User.create!(:client => client_emerson, :participant_id => "tester", :email => 'tester@mailinator.com', :password => "password", :password_confirmation => "password", :full_name => "test user", :mobile_number => "1234567890", :user_role_id => emerson_user_role.id)
user2 = User.create!(:client => client_emerson, :participant_id => "new_tester", :email => 'bvc@mailinator.com', :password => "password", :password_confirmation => "password", :full_name => "bvc user", :mobile_number => "1234567890", :user_role_id => emerson_user_role.id)
user3 = User.create!(:client => client_emerson, :participant_id => "snehaka", :email => 'snehaka@thoughtworks.com', :password => "password", :password_confirmation => "password", :full_name => "sneha ka", :mobile_number => "1234567890", :user_role_id => emerson_user_role.id)
user4 = User.create!(:client => client_emerson, :participant_id => "cukeuser", :email => 'cukeuser@mailinator.com', :password => "password", :password_confirmation => "password", :full_name => "cuke user", :mobile_number => "1234567890", :user_role_id => emerson_user_role.id)

emerson_single_redemption_user2 = User.create!(:client => client_emerson, :participant_id => "suresh", :email => 'suresh.axis@mailinator.com', :password => "password", :password_confirmation => "password", :full_name => "Suresh Chopra", :mobile_number => "1234567890", :user_role_id => emerson_user_role.id)
emerson_single_redemption_user3 = User.create!(:client => client_emerson, :participant_id => "vinod", :email => 'vinod.axis@mailinator.com', :password => "password", :password_confirmation => "password", :full_name => "Vinod Chopra", :mobile_number => "1234567890", :user_role_id => emerson_user_role.id)

associate_targets_and_achievements({:user_id => user1.id, :total_points => 20000, :scheme_id => emerson_active_scheme.id}, "level1", "all")
associate_targets_and_achievements({:user_id => user2.id, :total_points => 85000, :scheme_id => emerson_active_scheme.id}, "level1", "all")
associate_targets_and_achievements({:user_id => user3.id, :total_points => 85000, :scheme_id => emerson_active_scheme.id}, "level1", "all")
associate_targets_and_achievements({:user_id => user4.id, :total_points => 85000, :scheme_id => emerson_active_scheme.id}, "level1", "all")
associate_targets_and_achievements({:user_id => user4.id, :total_points => 85000, :scheme_id => emerson_past_scheme.id}, "level1", "all")
associate_targets_and_achievements({:user_id => user4.id, :total_points => 85000, :scheme_id => emerson_future_scheme.id}, "level1", "all")

associate_targets_and_achievements({:current_achievements => 15_000, :scheme_id => emerson_single_redemption_scheme.id, :user_id => user1.id}, "level1", "platinum", {:silver => 10_000, :gold => 30_000, :platinum => 80_000})
associate_targets_and_achievements({:current_achievements => 65000, :scheme_id => emerson_single_redemption_scheme.id, :user_id => user2.id}, "level2", "gold", {:silver => 10_000, :gold => 60_000, :platinum => 1_80_000})
associate_targets_and_achievements({:current_achievements => 65000, :scheme_id => emerson_single_redemption_scheme.id, :user_id => user3.id}, "level3", "silver", {:silver => 10_000, :gold => 60_000, :platinum => 1_80_000})

electronics = Category.create!(:title => "Electronics")
home_appliances = Category.create!(:title => "Home Appliances")
home_entertainment = Category.create!(:title => "Home Entertainment")
home_furnishing = Category.create!(:title => "Home Furnishing")
it = Category.create!(:title => "IT")
lifestyle = Category.create!(:title => "Lifestyle")

mobile = electronics.children.create!(:title => "Mobile")
cameras = electronics.children.create!(:title => "Cameras")
portable_electronics = electronics.children.create!(:title => "Portable Electronics")

air_conditioner = home_appliances.children.create!(:title => "Air Conditioner")
kitchenware = home_appliances.children.create!(:title => "Kitchenware")
refrigerator = home_appliances.children.create!(:title => "Refrigerator")

television = home_entertainment.children.create!(:title => "Television")
home_theatre = home_entertainment.children.create!(:title => "Home Theatre Systems")

bedding = home_furnishing.children.create!(:title => "Bed Sheets and Covers")
carpets = home_furnishing.children.create!(:title => "Carpets and Rugs")


laptop = it.children.create!(:title => "Laptop")
headphones = it.children.create!(:title => "Headphones")

apparel = lifestyle.children.create!(:title => "Apparel")
watches = lifestyle.children.create!(:title => "Watches")


supplier = Supplier.create!(name: "Flipkart", address: "Delhi", phone_number: "01112345678", geographic_reach: "Pan India", delivery_time: "2-3 days", payment_terms: "10 days", description: "will support in future", additional_notes: "notes")
infibeam = Supplier.create!(name: "Infibeam", address: "Pune", phone_number: "02012345678", geographic_reach: "West India", delivery_time: "3-4 days", payment_terms: "15 days", description: "default supplier", additional_notes: "notes")

s3 = Item.create(:category_id => mobile.id, :title => 'Samsung s3', :description => "Samsung I9300 Galaxy S III Android smartphone. Announced 2012, May. Features 3G, 4.8\" Super AMOLED capacitive touchscreen, 8 MP camera, Wi-Fi, GPS", :bvc_price => 42_000, :image => File.new(image_path + 'items/s3.jpg'))
s3.item_suppliers.create!(:is_preferred => true, :supplier_margin => 4, :supplier_id => supplier.id, :mrp => 43000, :channel_price => 39000)
s3.item_suppliers.create!(:supplier_id => infibeam.id, :mrp => 43000, :channel_price => 39300)
ClientItem.create(:deleted => false, :client_price => 43_000, :client_catalog_id => emerson_catalog.id, :item_id => s3.id)


macbook = Item.create(:category_id => laptop.id, :title => 'MacBook Pro', :description => "The MacBook Pro is a line of Macintosh portable computers introduced in January 2006 by Apple Inc., and now in its third generation.", :bvc_price => 1_20_000, :image => File.new(image_path + 'items/macbook.jpg'))
macbook.item_suppliers.create!(:is_preferred => true, :supplier_margin => 5.6, :supplier_id => supplier.id, :mrp => 1_30_000, :channel_price => 1_10_000)
ClientItem.create(:deleted => false, :client_price => 1_25_000, :client_catalog_id => emerson_catalog.id, :item_id => macbook.id)

steel_watch = Item.create(:category_id => watches.id, :title => 'Steel Dial Watch', :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla diam risus, sagittis at ultrices ac, fringilla accumsan purus. Morbi aliquet ultricies orci, in dignissim tortor tempus in. Donec adipiscing congue laoreet. Aliquam sagittis egestas molestie. Duis laoAliquam sagittis egestas molestie.", :bvc_price => 4500, :image => File.new(image_path + 'items/dialwatch.jpg'))
steel_watch.item_suppliers.create!(:is_preferred => true, :supplier_margin => 33.33, :supplier_id => supplier.id, :mrp => 6000, :channel_price => 4000)
ClientItem.create(:deleted => false, :client_price => 5000, :client_catalog_id => emerson_catalog.id, :item_id => steel_watch.id)

black_tie = Item.create(:category_id => apparel.id, :title => 'Black Tie', :description => "Complete your formal ensemble by sporting this formal necktie from the house of Park Avenue and make heads turn. This solid maroon tie for men is finely tailored from silk blend to give your tie a wrinkle free look. The shiny Park Avenue apparel is a woven tie ", :bvc_price => 40, :image => File.new(image_path + 'items/blacktie.jpg'))
black_tie.item_suppliers.create!(:is_preferred => true, :supplier_margin => 25, :supplier_id => supplier.id, :mrp => 40, :channel_price => 30)
ClientItem.create(:deleted => false, :client_price => 35, :client_catalog_id => emerson_catalog.id, :item_id => black_tie.id)

leather_belt = Item.create(:category_id => apparel.id, :title => 'Leather Belt', :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla diam risus, sagittis at ultrices ac, fringilla accumsan purus. Morbi aliquet ultricies orci, in dignissim tortor tempus in. Donec adipiscing congue laoreet. Aliquam sagittis egestas molestie. Duis lao", :bvc_price => 800, :image => File.new(image_path + 'items/leatherbelt.jpg'))
leather_belt.item_suppliers.create!(:is_preferred => true, :supplier_margin => 30, :supplier_id => supplier.id, :mrp => 1000, :channel_price => 700)
ClientItem.create(:deleted => false, :client_price => 900, :client_catalog_id => emerson_catalog.id, :item_id => leather_belt.id)

silver_bangles = Item.create(:category_id => apparel.id, :title => 'Silver Bangles', :description => "Quisque bibendum neque quis quam mattis vulputate. Praesent ultricies iaculis elit at pulvinar. Donec ullamcorper felis diam. Ut purus neque, eleifend nec rhoncus nec, adipiscing ac lacus. In ipsum nibh, cursus nec fermentum nec, venenatis rhoncus nulla. Vestibulum in tellus ac urna lacin", :bvc_price => 1500, :image => File.new(image_path + 'items/bangles.jpg'))
silver_bangles.item_suppliers.create!(:is_preferred => true, :supplier_margin => 40, :supplier_id => supplier.id, :mrp => 2000, :channel_price => 1200)
ClientItem.create(:deleted => false, :client_price => 1100, :client_catalog_id => emerson_catalog.id, :item_id => silver_bangles.id)

diamond_ring = Item.create(:category_id => apparel.id, :title => 'Diamond Ring', :description => "Quisque bibendum neque quis quam mattis vulputate. Praesent ultricies iaculis elit at pulvinar. Donec ullamcorper felis diam. Ut purus neque, eleifend nec rhoncus nec, adipiscing ac lacus. In ipsum nibh, cursus nec ferme", :bvc_price => 12000, :image => File.new(image_path + 'items/diamondring.jpg'))
diamond_ring.item_suppliers.create!(:is_preferred => true, :supplier_margin => 45, :supplier_id => supplier.id, :mrp => 20000, :channel_price => 11000)
ClientItem.create(:deleted => false, :client_price => 11900, :client_catalog_id => emerson_catalog.id, :item_id => diamond_ring.id)

yellow_bag = Item.create(:category_id => apparel.id, :title => 'Yellow Bag', :description => "Yellow double frame handbag with short handles, synthetic leather upper", :bvc_price => 1000, :image => File.new(image_path + 'items/yellowbag.jpg'))
yellow_bag.item_suppliers.create!(:is_preferred => true, :supplier_margin => 40, :supplier_id => supplier.id, :mrp => 2000, :channel_price => 900)
ClientItem.create(:deleted => false, :client_price => 1500, :client_catalog_id => emerson_catalog.id, :item_id => yellow_bag.id)

arvin_ac = Item.create(:category_id => air_conditioner.id, :title => 'Arvin AC', :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla diam risus, sagittis at ultrices ac, fringilla accumsan purus. Morbi aliquet ultricies orci, in dignissim tortor tempus in. Donec adipiscing congue laoreet. Aliquam sagittis egestas molestie. Duis lao", :bvc_price => 20000, :image => File.new(image_path + 'items/ArvinAC.jpg'))
arvin_ac.item_suppliers.create!(:is_preferred => true, :supplier_margin => 11, :supplier_id => supplier.id, :mrp => 18000, :channel_price => 16000)
ClientItem.create(:deleted => false, :client_price => 17000, :client_catalog_id => emerson_catalog.id, :item_id => arvin_ac.id)

voltas_ac = Item.create(:category_id => air_conditioner.id, :title => 'Voltas AC', :description => "Sed sodales facilisis ante, ut euismod mi suscipit tincidunt. Donec rhoncus adipiscing risus ac porttitor. Vivamus justo enim, adipiscing eu sollicitudin sit amet, mattis id lacus. Praesent sit amet risus at lorem laoreet facilisis. Curabitur nec ipsum sed leo pretium lacinia faucibus vel odio. Ut c", :bvc_price => 40_000, :image => File.new(image_path + 'items/VoltasAC.jpeg'))
voltas_ac.item_suppliers.create!(:is_preferred => true, :supplier_margin => 16, :supplier_id => supplier.id, :mrp => 45_000, :channel_price => 38_000)
ClientItem.create(:deleted => false, :client_price => 41_000, :client_catalog_id => emerson_catalog.id, :item_id => voltas_ac.id)

cooler = Item.create(:category_id => kitchenware.id, :title => 'Valerio water cooler', :description => "Sed sodales facilisis ante, ut euismod mi suscipit tincidunt. Donec rhoncus adipiscing risus ac porttitor. Vivamus justo enim, adipiscing eu sollicitudin sit amet, mattis id lacus. Praesent sit amet risus at lorem laoreet facilis", :bvc_price => 15_000, :image => File.new(image_path + 'items/Valerio.jpg'))
cooler.item_suppliers.create!(:is_preferred => true, :supplier_margin => 30, :supplier_id => supplier.id, :mrp => 18_000, :channel_price => 14_000)
ClientItem.create(:deleted => false, :client_price => 16_000, :client_catalog_id => emerson_catalog.id, :item_id => cooler.id)

whirlpool = Item.create(:category_id => refrigerator.id, :title => 'Red Whirlpool Refrigerator', :description => "Sed sodales facilisis ante, ut euismod mi suscipit tincidunt. Donec rhoncus adipiscing risus ac porttitor. Vivamus justo enim, adipiscing eu sollicitudin sit amet, mattis id lacus. Praesent sit amet risus at lorem laoreet facilis", :bvc_price => 50_000, :image => File.new(image_path + 'items/Whirlpool.jpg'))
whirlpool.item_suppliers.create!(:is_preferred => true, :supplier_margin => 4, :supplier_id => supplier.id, :mrp => 52_000, :channel_price => 49_000)
ClientItem.create(:deleted => false, :client_price => 51_000, :client_catalog_id => emerson_catalog.id, :item_id => whirlpool.id)

godrej = Item.create(:category_id => refrigerator.id, :title => 'Pink Godrej Refrigerator', :description => "Sed sodales facilisis ante, ut euismod mi suscipit tincidunt. Donec rhoncus adipiscing risus ac porttitor. Vivamus justo enim, adipiscing eu sollicitudin sit amet, mattis id lacus. Praesent sit amet risus at lorem laoreet facilis", :bvc_price => 32_000, :image => File.new(image_path + 'items/godrej.jpg'))
godrej.item_suppliers.create!(:is_preferred => true, :supplier_margin => 12, :supplier_id => supplier.id, :mrp => 35_000, :channel_price => 31_000)
ClientItem.create(:deleted => false, :client_price => 33_000, :client_catalog_id => emerson_catalog.id, :item_id => godrej.id)


panasonic = Item.create(:category_id => television.id, :title => 'Panasonic Flat Screen', :description => "Sed sodales facilisis ante, ut euismod mi suscipit tincidunt. Donec rhoncus adipiscing risus ac porttitor. Vivamus justo enim, adipiscing eu sollicitudin sit amet, mattis id lacus. Praesent sit amet risus at lorem laoreet facilis", :bvc_price => 16900, :image => File.new(image_path + 'items/Panasonic.jpg'))
panasonic.item_suppliers.create!(:is_preferred => true, :supplier_margin => 10, :supplier_id => supplier.id, :mrp => 18_900, :channel_price => 16_000)
ClientItem.create(:deleted => false, :client_price => 17_000, :client_catalog_id => emerson_catalog.id, :item_id => panasonic.id)

samsung = Item.create(:category_id => television.id, :title => 'Samsung Flat Screen', :description => "Quisque bibendum neque quis quam mattis vulputate. Praesent ultricies iaculis elit at pulvinar. Donec ullamcorper felis diam. Ut purus neque, eleifend nec rhoncus nec, adipiscing ac lacus. In ipsum nibh, cursus nec fermentum nec, venenatis rhoncus nulla. Vestibulum in tellus ac urna laciurna lacin", :bvc_price => 20_000, :image => File.new(image_path + 'items/SamsungFS.jpg'))
samsung.item_suppliers.create!(:is_preferred => true, :supplier_margin => 14, :supplier_id => supplier.id, :mrp => 22_000, :channel_price => 19_000)
ClientItem.create(:deleted => false, :client_price => 21_500, :client_catalog_id => emerson_catalog.id, :item_id => samsung.id)

home_theatre = Item.create(:category_id => home_theatre.id, :title => 'Mitashi Home Theatre', :description => "Quisque bibendum neque quis quam mattis vulputate. Praesent ultricies iaculis elit at pulvinar. Donec ullamcorper felis diam. Ut purus neque, eleifend nec rhoncus nec, adipiscing ac lacus. In ipsum nibh, cursus nec fermentum nec, venenatis rhoncus nulla. Vestibulum in tellus ac urna laciurna lacin", :bvc_price => 9899, :image => File.new(image_path + 'items/MitashiHT.jpg'))
home_theatre.item_suppliers.create!(:is_preferred => true, :supplier_margin => 24, :supplier_id => supplier.id, :mrp => 10_600, :channel_price => 8_000)
ClientItem.create(:deleted => false, :client_price => 9999, :client_catalog_id => emerson_catalog.id, :item_id => home_theatre.id)

flowers = Item.create(:category_id => bedding.id, :title => 'Picaso Flowers Bedsheets', :description => "One of the country's largest home furnishing brands, Picaso definitely knows how to impress with their bedlinen. In pop colours and featuring attractive prints, all pieces are impeccably finished. So go ahead, give your home a stylish makeover and make it a place of your dreams", :bvc_price => 2_000, :image => File.new(image_path + 'items/Picaso-flowers.jpg'))
flowers.item_suppliers.create!(:is_preferred => true, :supplier_margin => 24, :supplier_id => supplier.id, :mrp => 2_500, :channel_price => 1_900)
ClientItem.create(:deleted => false, :client_price => 2_200, :client_catalog_id => emerson_catalog.id, :item_id => flowers.id)

polka = Item.create(:category_id => bedding.id, :title => 'Picaso Polka Bedsheets', :description => "One of the country's largest home furnishing brands, Picaso definitely knows how to impress with their bedlinen. In pop colours and featuring attractive prints, all pieces are impeccably finished. So go ahead, give your home a stylish makeover and make it a place of your dreams", :bvc_price => 9000, :image => File.new(image_path + 'items/Picaso-polka.jpg'))
polka.item_suppliers.create!(:is_preferred => true, :supplier_margin => 20, :supplier_id => supplier.id, :mrp => 10_000, :channel_price => 8_000)
ClientItem.create(:deleted => false, :client_price => 9_500, :client_catalog_id => emerson_catalog.id, :item_id => polka.id)

rose = Item.create(:category_id => bedding.id, :title => 'Picaso Rose Bedsheets', :description => "One of the country's largest home furnishing brands, Picaso definitely knows how to impress with their bedlinen. In pop colours and featuring attractive prints, all pieces are impeccably finished. So go ahead, give your home a stylish makeover and make it a place of your dreams", :bvc_price => 10000, :image => File.new(image_path + 'items/Picaso-rose.jpg'))
rose.item_suppliers.create!(:is_preferred => true, :supplier_margin => 9.1, :supplier_id => supplier.id, :mrp => 11_000, :channel_price => 9999)
ClientItem.create(:deleted => false, :client_price => 10_500, :client_catalog_id => emerson_catalog.id, :item_id => rose.id)

pattern_rug = Item.create(:category_id => carpets.id, :title => 'Pattern Rug', :description => "This attractive rug is made from quality jute and can be incorporated anywhere in your home.", :bvc_price => 3_500, :image => File.new(image_path + 'items/patterncarpet.jpg'))
pattern_rug.item_suppliers.create!(:is_preferred => true, :supplier_margin => 47.27, :supplier_id => supplier.id, :mrp => 5_500, :channel_price => 2_900)
ClientItem.create(:deleted => false, :client_price => 4_000, :client_catalog_id => emerson_catalog.id, :item_id => pattern_rug.id)

blue_rug = Item.create(:category_id => carpets.id, :title => 'Blue Rug', :description => "This attractive rug is made from quality jute and can be incorporated anywhere in your home.", :bvc_price => 1000, :image => File.new(image_path + 'items/bluecarpet.jpg'))
blue_rug.item_suppliers.create!(:is_preferred => true, :supplier_margin => 25, :supplier_id => supplier.id, :mrp => 1_200, :channel_price => 900)
ClientItem.create(:deleted => false, :client_price => 1_100, :client_catalog_id => emerson_catalog.id, :item_id => blue_rug.id)

mic_headphones = Item.create(:category_id => headphones.id, :title => 'Philips Headphones with Mic', :description => "This headset is ideal for people on the move who want premium sound with perfect comfort.", :bvc_price => 200, :image => File.new(image_path + 'items/Philips-SH.jpg'))
mic_headphones.item_suppliers.create!(:is_preferred => true, :supplier_margin => 50, :supplier_id => supplier.id, :mrp => 300, :channel_price => 150)
client_item_mic_headphones = ClientItem.create(:deleted => false, :client_price => 180, :client_catalog_id => emerson_catalog.id, :item_id => mic_headphones.id)

headphones = Item.create(:category_id => headphones.id, :title => 'Philips Headphones', :description => "This headset is ideal for people on the move who want premium sound with perfect comfort.", :bvc_price => 600, :image => File.new(image_path + 'items/Philips.jpg'))
headphones.item_suppliers.create!(:is_preferred => true, :supplier_margin => 50, :supplier_id => supplier.id, :mrp => 1_000, :channel_price => 500)
client_item_headphones = ClientItem.create(:deleted => false, :client_price => 700, :client_catalog_id => emerson_catalog.id, :item_id => headphones.id)

hand_held_camera = Item.create(:category_id => cameras.id, :title => 'Olympus Hand-held camera', :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla diam risus, sagittis at ultrices ac, fringilla accumsan purus. Morbi aliquet ultricies orci, in dignissim tortor tempus in", :bvc_price => 14_840, :image => File.new(image_path + 'items/Olympus.jpg'))
hand_held_camera.item_suppliers.create!(:is_preferred => true, :supplier_margin => 13.5, :supplier_id => supplier.id, :mrp => 16_000, :channel_price => 13_840)
ClientItem.create(:deleted => false, :client_price => 15_840, :client_catalog_id => emerson_catalog.id, :item_id => hand_held_camera.id)

sling_shot = Item.create(:category_id => cameras.id, :title => 'Sling shot', :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla diam risus, sagittis at ultrices ac, fringilla accumsan purus. Morbi aliquet ultricies orci, in dignissim tortor tempus in", :bvc_price => 5996, :image => File.new(image_path + 'items/Geniusgshot.jpg'))
sling_shot.item_suppliers.create!(:is_preferred => true, :supplier_margin => 28.58, :supplier_id => supplier.id, :mrp => 6_996, :channel_price => 4_996)
ClientItem.create(:deleted => false, :client_price => 6_000, :client_catalog_id => emerson_catalog.id, :item_id => sling_shot.id)

handycam = Item.create(:category_id => cameras.id, :title => 'JVC Handycam', :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla diam risus, sagittis at ultrices ac, fringilla accumsan purus. Morbi aliquet ultricies orci, in dignissim tortor tempus in", :bvc_price => 10_000, :image => File.new(image_path + 'items/JVC.jpg'))
handycam.item_suppliers.create!(:is_preferred => true, :supplier_margin => 25, :supplier_id => supplier.id, :mrp => 12_000, :channel_price => 9_000)
ClientItem.create(:deleted => false, :client_price => 11_000, :client_catalog_id => emerson_catalog.id, :item_id => handycam.id)

screenguard = Item.create(:category_id => portable_electronics.id, :title => 'Samsung Screenguard', :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla diam risus, sagittis at ultrices ac, fringilla accumsan purus. Morbi aliquet ultricies orci, in dignissim tortor tempus in", :bvc_price => 499, :image => File.new(image_path + 'items/Screenguard.jpg'))
screenguard.item_suppliers.create!(:is_preferred => true, :supplier_margin => 25.16, :supplier_id => supplier.id, :mrp => 600, :channel_price => 449)
ClientItem.create(:deleted => false, :client_price => 550, :client_catalog_id => emerson_catalog.id, :item_id => screenguard.id)


emerson_active_scheme.client_items = ClientItem.find_all_by_client_catalog_id(emerson_catalog.id)
emerson_active_scheme.save!

[handycam, sling_shot, screenguard].each { |item| ClientItem.create(:deleted => false, :client_price => 35_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }
[panasonic, godrej, whirlpool, flowers].each { |item| ClientItem.create(:deleted => false, :client_price => 30_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }
[blue_rug, pattern_rug, polka, rose].each { |item| ClientItem.create(:deleted => false, :client_price => 25_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }
[s3, hand_held_camera].each { |item| ClientItem.create(:deleted => false, :client_price => 30_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }
[steel_watch, silver_bangles].each { |item| ClientItem.create(:deleted => false, :client_price => 25_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }
[macbook, black_tie].each { |item| ClientItem.create(:deleted => false, :client_price => 20_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }
[yellow_bag, diamond_ring].each { |item| ClientItem.create(:deleted => false, :client_price => 20_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }
[arvin_ac, voltas_ac].each { |item| ClientItem.create(:deleted => false, :client_price => 15_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }
[mic_headphones, headphones, home_theatre, cooler].each { |item| ClientItem.create(:deleted => false, :client_price => 10_000, :client_catalog_id => emerson_catalog.id, :item_id => item.id) }

def lookup_item(item, catalog)
  ClientItem.where(:client_catalog_id => catalog.id, :item_id => item.id).first
end

emerson_single_redemption_scheme.client_items = ClientItem.find_all_by_client_catalog_id(emerson_catalog.id)
emerson_single_redemption_scheme.save!

emerson_single_redemption_scheme.level_clubs.with_level('level3').with_club('platinum').first.catalog.add([panasonic, godrej, whirlpool, voltas_ac, silver_bangles].collect { |item| lookup_item(item, emerson_catalog) })
emerson_single_redemption_scheme.level_clubs.with_level('level3').with_club('gold').first.catalog.add([handycam, sling_shot, screenguard, hand_held_camera, headphones].collect { |item| lookup_item(item, emerson_catalog) })
emerson_single_redemption_scheme.level_clubs.with_level('level3').with_club('silver').first.catalog.add([blue_rug, pattern_rug, rose, flowers, black_tie].collect { |item| lookup_item(item, emerson_catalog) })

emerson_single_redemption_scheme.level_clubs.with_level('level2').with_club('platinum').first.catalog.add([s3, hand_held_camera, handycam, voltas_ac].collect { |item| lookup_item(item, emerson_catalog) })
emerson_single_redemption_scheme.level_clubs.with_level('level2').with_club('gold').first.catalog.add([steel_watch, silver_bangles, mic_headphones, arvin_ac].collect { |item| lookup_item(item, emerson_catalog) })
emerson_single_redemption_scheme.level_clubs.with_level('level2').with_club('silver').first.catalog.add([black_tie, polka, rose, headphones].collect { |item| lookup_item(item, emerson_catalog) })

emerson_single_redemption_scheme.level_clubs.with_level('level1').with_club('platinum').first.catalog.add([home_theatre, diamond_ring, macbook, s3, whirlpool].collect { |item| lookup_item(item, emerson_catalog) })
emerson_single_redemption_scheme.level_clubs.with_level('level1').with_club('gold').first.catalog.add([arvin_ac, voltas_ac, sling_shot, cooler, yellow_bag].collect { |item| lookup_item(item, emerson_catalog) })
emerson_single_redemption_scheme.level_clubs.with_level('level1').with_club('silver').first.catalog.add([mic_headphones, headphones, polka, screenguard, silver_bangles].collect { |item| lookup_item(item, emerson_catalog) })

emerson_active_scheme.level_clubs.with_level('level1').with_club('all').first.catalog.add([panasonic, godrej, whirlpool, voltas_ac, silver_bangles].collect { |item| lookup_item(item, emerson_catalog) })

AdminUser.create!(:username => 'admin', :email => 'admin@birdvision.in', :password => "password", :password_confirmation => "password", :role => AdminUser::Roles::SUPER_ADMIN).update_attribute(:manage_roles, true)

client_manager_admin_user = AdminUser.create!(:username => 'client_manager', :email => 'client_manager@mailinator.com', :password => "password", :password_confirmation => "password", :role => AdminUser::Roles::CLIENT_MANAGER)

client_manager = ClientManager.create!(client: client_emerson, admin_user: client_manager_admin_user, email: 'client_maanger@mailinator.com',
                                       mobile_number: '1234567890', name: 'Client Manager')

reseller_admin_user = AdminUser.create!(username: 'bvc.1', password: "password", password_confirmation: "password", role: AdminUser::Roles::RESELLER,
                                        email: "bvc.smoke.chacha@mailinator.com")
reseller = Reseller.create!(:name => "Chacha Chaudhari", :email => 'bvc.smoke.chacha@mailinator.com', :phone_number => "9403012352", :admin_user => reseller_admin_user)
slabs = [Slab.new(:lower_limit => 50, :payout_percentage => 10), Slab.new(:lower_limit => 500, :payout_percentage => 20), Slab.new(:lower_limit => 5000, :payout_percentage => 30)]
ClientReseller.create!(:client_id => client_emerson.id, :reseller_id => reseller.id, :payout_start_date => Date.today, :finders_fee => "1234", :slabs => slabs)

ItemSupplier.all.each { |is| is.update_attributes(:geographic_reach => is.supplier.geographic_reach, :delivery_time => is.supplier.delivery_time) }

load_smoke_data()
Sunspot.remove_all!
Sunspot.index! ClientItem.all