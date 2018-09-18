require 'spec_helper'

describe SchemeBudget do
  it "should return return true if total uploaded points exceed total budget for a scheme" do
    scheme = Fabricate(:scheme, :total_budget_in_rupees => 5_000, :client => Fabricate(:client, :client_name => "Axis", :points_to_rupee_ratio => 2))
    Fabricate(:user_scheme, :total_points => 15_000, :scheme => scheme, :user => Fabricate(:user))

    scheme_budget = SchemeBudget.for_schemes([scheme]).first
    scheme_budget.exceeded?.should == true
  end

  it "should return total redemption in points and rupees for a scheme" do
    scheme = Fabricate(:scheme, :redemption_start_date => Date.yesterday - 2.days, :redemption_end_date => Date.today + 3.days,
                       :total_budget_in_rupees => 50_000)
    Fabricate(:order_item, :price_in_rupees => 35, :points_claimed => 70, :scheme => scheme)
    Fabricate(:order_item, :price_in_rupees => 2111, :points_claimed => 4242, :scheme => scheme)
    Fabricate(:order_item, :price_in_rupees => 500, :points_claimed => 1000, :scheme => scheme)
    scheme_budget = SchemeBudget.for_schemes([scheme]).first

    scheme_budget.total_points_redeemed.should == 5312
    scheme_budget.total_rupees_redeemed.should == 2646
  end

  it "should give total uploaded points and rupees for all users under that scheme" do
    scheme = Fabricate(:scheme, :redemption_start_date => Date.yesterday - 2.days, :redemption_end_date => Date.today + 3.days,
                       :total_budget_in_rupees => 50_000)
    Fabricate(:user_scheme, :total_points => 10_000, :scheme => scheme)
    Fabricate(:user_scheme, :total_points => 5_000, :scheme => scheme)
    Fabricate(:user_scheme, :total_points => 20_000, :scheme => scheme)

    scheme_budget = SchemeBudget.for_schemes([scheme]).first

    scheme_budget.total_points_uploaded.should == 35_000
    scheme_budget.total_rupees_uploaded.should == 35_000 / 10
  end

  it "should return scheme budget in points and rupees" do
    scheme = Fabricate(:scheme, :client => Fabricate(:client, :points_to_rupee_ratio => 2), :total_budget_in_rupees => 50000)
    scheme_budget = SchemeBudget.for_schemes([scheme]).first

    scheme_budget.total_budget_in_points.should == 1_00_000
  end

end