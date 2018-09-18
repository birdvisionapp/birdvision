require 'spec_helper'
describe AdminDashboard do
  before :each do
    @acme = Fabricate(:client, :client_name => "Acme Inc", :points_to_rupee_ratio => 2)
    @client_manager_admin_user = Fabricate(:client_manager_admin_user)
    @client_manager = Fabricate(:client_manager, :client => @acme, :admin_user => @client_manager_admin_user)
    @ability = Ability.new(@client_manager_admin_user)
    @wayne_corp = Fabricate(:client, :client_name => "Wayne Corporation", :points_to_rupee_ratio => 2)
    @upcoming_scheme = Fabricate(:future_scheme, :name => "upcoming_scheme", :client => @acme)
    @dead_scheme = Fabricate(:expired_scheme, :name => "Past Scheme", :client => @acme)
    @gold_rush = Fabricate(:scheme, :name => "Gold Rush", :client => @acme)
    @silver_rush = Fabricate(:scheme, :name => "Silver Rush", :client => @acme)
    @gold_sprint = Fabricate(:scheme, :name => "Gold Sprint", :client => @acme)
    @batman_scheme = Fabricate(:scheme, :name => "Silver Sprint", :client => @wayne_corp)
    @ramesh = Fabricate(:user, :client => @acme, :activation_status => User::ActivationStatus::ACTIVATED, :status => User::Status::ACTIVE)
    @suresh = Fabricate(:user, :client => @acme, :activation_status => User::ActivationStatus::LINK_NOT_SENT, :status => User::Status::ACTIVE)
    @akhilesh = Fabricate(:user, :client => @acme, :activation_status => User::ActivationStatus::NOT_ACTIVATED, :status => User::Status::INACTIVE)
    @rajesh = Fabricate(:user, :client => @acme, :activation_status => User::ActivationStatus::ACTIVATED, :status => User::Status::INACTIVE)
    @joker = Fabricate(:user, :client => @wayne_corp, :activation_status => User::ActivationStatus::ACTIVATED, :status => User::Status::PENDING)
  end
  let!(:dashboard) { AdminDashboard.new(@client_manager_admin_user) }
  it "should return scheme stats for the client" do
    single_redemption_scheme = Fabricate(:single_redemption_scheme, :client => @acme)
    Fabricate(:scheme, :name => "Silver Sprint", :client => @acme)
    Fabricate(:user_scheme, :user => @ramesh, :scheme => @gold_rush, :total_points => 10_000)
    Fabricate(:user_scheme, :user => @suresh, :scheme => @silver_rush, :total_points => 20_000)
    Fabricate(:user_scheme, :user => @suresh, :scheme => single_redemption_scheme, :current_achievements => 20_000)

    dashboard.scheme_stats.should == {:redeemable => 5, :past => 1, :upcoming => 1}
    dashboard.top_redeemable_schemes.should =~ [single_redemption_scheme, @gold_sprint, @silver_rush, @gold_rush]
    dashboard.redeemable_schemes_budget.should == 15_000 #(10,000 + 20,000) / 2 where 2 is the point to rupee ratio
  end

  it "should return user stats scoped for the client" do
    Fabricate(:user_scheme, :user => @ramesh, :scheme => @gold_rush)
    Fabricate(:user_scheme, :user => @suresh, :scheme => @gold_sprint)
    Fabricate(:user_scheme, :user => @akhilesh, :scheme => @dead_scheme)
    Fabricate(:user_scheme, :user => @rajesh, :scheme => @upcoming_scheme)
    Fabricate(:user_scheme, :user => @joker, :scheme => @batman_scheme)

    dashboard.participant_stats.should == {"active" => 2, "inactive" => 2, "pending" => 1}
  end

  it "should return order stats scoped for the client" do
    acme_client_item = Fabricate(:client_item, :client_catalog => @acme.client_catalog)
    wayne_client_item = Fabricate(:client_item, :client_catalog => @acme.client_catalog)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @rajesh), :scheme => @gold_rush,
              :client_item => acme_client_item, :status => :delivery_in_progress, :points_claimed => 1_000)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @ramesh), :scheme => @gold_sprint,
              :client_item => acme_client_item, :status => :new, :points_claimed => 2_000)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @rajesh), :scheme => @silver_rush,
              :client_item => acme_client_item, :status => :delivered, :points_claimed => 3_000)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @rajesh), :scheme => @gold_rush,
              :client_item => acme_client_item, :status => :sent_to_supplier, :points_claimed => 4_000)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @ramesh), :scheme => @gold_rush,
              :client_item => acme_client_item, :status => :incorrect, :points_claimed => 5_000)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @rajesh), :scheme => @gold_rush,
              :client_item => acme_client_item, :status => :refunded, :points_claimed => 6_000)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @joker), :scheme => @batman_scheme,
              :client_item => wayne_client_item, :status => :incorrect, :points_claimed => 6_000)

    dashboard.order_stats.should == {:new => 1, :sent_to_supplier => 1, :delivery_in_progress => 1, :delivered => 1, :incorrect => 1, :refunded => 1}
  end

  it "should return redemption stats for schemes for non incorrect order_items" do
    acme_client_item = Fabricate(:client_item, :client_catalog => @acme.client_catalog)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @ramesh), :scheme => @gold_rush,
              :client_item => acme_client_item, :price_in_rupees => 1_234, :points_claimed => 12_340)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @suresh), :scheme => @silver_rush,
              :client_item => acme_client_item, :price_in_rupees => 5_670, :points_claimed => 56_700)
    Fabricate(:order_item, :order => Fabricate(:order, :user => @suresh), :scheme => @silver_rush,
              :client_item => acme_client_item, :price_in_rupees => 5_670, :status => :incorrect, :points_claimed => 56_700)

    dashboard.redemption_per_scheme.should == 6_904
  end
end