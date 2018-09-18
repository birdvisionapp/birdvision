def load_smoke_data
  image_path = "." + "/public/images/"
  bvc_point_based_client = Client.create!(:client_name => "bvc-point-based", :code => "bvc-point-based", :contact_email => "bvc-point-based@mailinator.com", :points_to_rupee_ratio => 2, :address => 'test address')
  point_based_client_catalog = bvc_point_based_client.create_client_catalog
  point_based_user_role = bvc_point_based_client.user_roles.create!(:name => "Point Based Role")
  bvc_point_based_client.save!

  bvc_club_based_client = Client.create!(:client_name => "bvc-club-based", :code => "bvc-club-based", :contact_email => "bvc-club-based@mailinator.com", :points_to_rupee_ratio => 1, :address => 'test address')
  club_based_client_catalog = bvc_club_based_client.create_client_catalog
  club_based_user_role = bvc_club_based_client.user_roles.create!(:name => "Club Based Role")
  bvc_club_based_client.save!


  bvc_point_based_scheme = Scheme.new(:name => 'bvc points scheme', :client_id => bvc_point_based_client.id, :start_date => Date.new(2012, 1, 1),
                                      :end_date => Date.new(2013, 1, 1), :redemption_start_date => Date.new(2013, 1, 21), :redemption_end_date => Date.new(2015, 1, 1),
                                      :poster => File.new(image_path + 'schemes/big_bang_dhamaka.png'),
                                      :hero_image => File.new(image_path + 'schemes/hero_bbd.png'), :single_redemption => false)
  bvc_point_based_scheme.create_level_clubs(%w(level1), %w(all))
  bvc_point_based_scheme.save!

  club_based_scheme = Scheme.new(:name => 'bvc club scheme', :client_id => bvc_club_based_client.id, :start_date => Date.new(2012, 1, 1),
                                 :end_date => Date.new(2013, 1, 1), :redemption_start_date => Date.new(2013, 1, 21), :redemption_end_date => Date.new(2015, 1, 1),
                                 :poster => File.new(image_path + 'schemes/big_bang_dhamaka.png'), :single_redemption => true)
  club_based_scheme.create_level_clubs(%w(level1 level2 level3), %w(platinum gold silver))

  club_based_scheme.save!

  bvc_point_based_user = User.create!(:client => bvc_point_based_client, :participant_id => "bvcuser", :email => 'bvcuser@mailinator.com', :password => "password", :password_confirmation => "password", :full_name => "bvc user", :mobile_number => "9403012352", :user_role_id => point_based_user_role.id)
  bvc_club_based_user = User.create!(:client => bvc_club_based_client, :participant_id => "bvcuser", :email => 'bvcuser@mailinator.com', :password => "password", :password_confirmation => "password",
    :full_name => "bvc user", :mobile_number => "9403012352", :user_role_id => club_based_user_role.id)


  UserScheme.create!(:user_id => bvc_point_based_user.id, :total_points => 2_00_00_000, :scheme_id => bvc_point_based_scheme.id,
                     :level => Level.with_scheme_and_level_name(bvc_point_based_scheme, 'level1').first, :club => Club.with_scheme_and_club_name(bvc_point_based_scheme, 'all').first)

  associate_targets_and_achievements({:user_id => bvc_club_based_user.id, :current_achievements => 15_000, :scheme_id => club_based_scheme.id}, "level1", "platinum", :silver => 10_000, :gold => 30_000, :platinum => 80_000)


  bvc_catagory = Category.create!(:title => "bvc-category")
  bvc_sub_category = bvc_catagory.children.create!(:title => "bvc-sub-category")
  bvc_supplier = Supplier.create!(name: "bvc-supplier", address: "Delhi", phone_number: "01112345678", geographic_reach: "Pan India", delivery_time: "2-3 days", payment_terms: "10 days", description: "will support in future", additional_notes: "notes")


  bvc_item = Item.create!(:category_id => bvc_sub_category.id, :title => 'bvc-item', :description => "Lorem Ipsum is simply dummy text of the printing and typesetting industry, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.", :bvc_price => 950, :image => File.new(image_path + 'items/macbook.jpg'))
  bvc_item.item_suppliers.create!(:is_preferred => true, :supplier_margin => 25, :supplier_id => bvc_supplier.id, :mrp => 1200, :channel_price => 900)
  ClientItem.create!(:deleted => false, :client_price => 1000, :client_catalog_id => point_based_client_catalog.id, :item_id => bvc_item.id)

  bvc_point_based_scheme.client_items = ClientItem.find_all_by_client_catalog_id(point_based_client_catalog.id)
  bvc_point_based_scheme.level_clubs.with_level('level1').with_club('all').first.catalog.add(ClientItem.find_all_by_client_catalog_id(point_based_client_catalog.id))
  bvc_point_based_scheme.save!

  bvc_club_based_client_item = ClientItem.create!(:deleted => false, :client_price => 100, :client_catalog_id => club_based_client_catalog.id, :item_id => bvc_item.id)
  club_based_scheme.client_items = ClientItem.find_all_by_client_catalog_id(club_based_client_catalog.id)
  club_based_scheme.save!

  club_based_scheme.level_clubs.with_level('level1').with_club('platinum').first.catalog.add([bvc_club_based_client_item])
  reseller_admin_user = AdminUser.create!(:username => 'bvc.reseller', :email => "bvc.smoke@mailinator.com", :password => "password", :password_confirmation => "password", :role => AdminUser::Roles::RESELLER)
  reseller = Reseller.create!(:name => "BVC reseller", :email => 'bvc.smoke@mailinator.com', :phone_number => "9403012352", :admin_user => reseller_admin_user)
  slabs = [Slab.new(:lower_limit => 50, :payout_percentage => 10), Slab.new(:lower_limit => 500, :payout_percentage => 20), Slab.new(:lower_limit => 5000, :payout_percentage => 30)]
  ClientReseller.create!(:client_id => bvc_point_based_client.id, :reseller_id => reseller.id, :payout_start_date => Date.today, :finders_fee => "1234", :slabs => slabs)
  client_manager_admin_user = AdminUser.create!(:username => 'bvc.client_manager', :email => 'bvc_client_manager@mailinator.com', :password => "password", :password_confirmation => "password", :role => AdminUser::Roles::CLIENT_MANAGER)

  client_manager = ClientManager.create!(client: bvc_point_based_client, admin_user: client_manager_admin_user, email: 'client_maanger@mailinator.com',
                                         mobile_number: '1234567890', name: 'BVC Client Manager')

end