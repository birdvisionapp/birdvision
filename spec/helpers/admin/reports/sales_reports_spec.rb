require 'spec_helper'

describe Admin::Reports::SalesReports do
  context "reports" do
    include Admin::Reports::SalesReports
    it "should generate orders report for reseller" do
      reseller = Fabricate(:reseller, :admin_user => @admin)
      client_reseller = Fabricate(:client_reseller, :reseller => reseller)

      scheme = Fabricate(:scheme, :client => client_reseller.client)
      order_item = Fabricate(:order_item, :scheme => scheme, :quantity => 2)
      order = order_item.order
      item = order_item.client_item.item
      reseller.orders_report_of([order_item]).should == "Order ID,Item Name,Quantity,Participant,Scheme,Status,Client Price,Points\n#{order.order_id},#{item.title},#{order_item.quantity},#{order.user.full_name},#{order_item.scheme.name},#{order_item.status.humanize},#{order_item.price_in_rupees},#{order_item.points_claimed}\n"
    end

    it "should generate participants report for reseller for point based client" do
      reseller = Fabricate(:reseller, :admin_user => @admin)
      client_reseller = Fabricate(:client_reseller, :reseller => reseller)

      scheme = Fabricate(:scheme, :client => client_reseller.client, :name => "bbd")
      user1 = Fabricate(:user)
      user_scheme1 = Fabricate(:user_scheme, :total_points => 10_000, :redeemed_points => 2_000,
                               :scheme => scheme, :user => user1)
      reseller.participants_report_of([user_scheme1]).should include("Scheme,Participant Id,Username,Full Name,Points uploaded,Points redeemed,Current Achievements,Rewards Redeemed\n" +
                                                                         "bbd,#{user1.participant_id},#{user1.username},#{user1.full_name},#{user_scheme1.total_points},#{user_scheme1.redeemed_points},20000,0\n")
    end

    it "should generate participants report for reseller of a client having single redemption scheme" do
      reseller = Fabricate(:reseller, :admin_user => @admin)
      client = Fabricate(:client)
      Fabricate(:client_reseller, :client => client, :reseller => reseller)

      scheme = Fabricate(:scheme, :single_redemption => true, :client => client, :name => "sbd")
      user1 = Fabricate(:user)
      user_scheme = Fabricate(:user_scheme, :current_achievements => 10_000, :total_points => 25_500,
                              :scheme => scheme, :user => user1)
      Fabricate(:order_item, :scheme => scheme, :order => Fabricate(:order, :user => user1), :price_in_rupees => 8_000)
      reseller.participants_report_of([user_scheme]).should include("Scheme,Participant Id,Username,Full Name,Points uploaded,Points redeemed,Current Achievements,Rewards Redeemed\n" +
                                                                        "sbd,#{user1.participant_id},#{user1.username},#{user1.full_name},25500,0,#{user_scheme.current_achievements},8000\n")
    end
  end

end
