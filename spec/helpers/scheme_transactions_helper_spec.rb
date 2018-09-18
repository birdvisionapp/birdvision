require 'spec_helper'

describe SchemeTransactionsHelper do

  context "points summary" do
    let(:scheme) { Fabricate(:scheme_3x3, :name => 'Test Scheme') }
    let(:user_scheme) { Fabricate(:user_scheme, :scheme => scheme, :total_points => 10_000, :redeemed_points => 2_000) }
    let(:user) { user_scheme.user }
    let(:order) { Fabricate(:order) }
    let(:order_item) { Fabricate(:order_item, :scheme => user_scheme.scheme,
        :order => order,
        :quantity => 2, :status => :incorrect, :price_in_rupees => 10_000,
        :points_claimed => 2_000)}


    it "should return points summary info based on the type" do
      helper.stub(:current_user).and_return(user)
      helper.points_summary_info(:total).should == '10,000'
      helper.points_summary_info(:redeemed).should == '2,000'
      helper.points_summary_info(:remaining).should == '8,000'
    end

    it "should return points summary based on the scheme transaction" do
      helper.stub(:current_user).and_return(user)
      helper.points_summary_for(Fabricate(:scheme_transaction, :points => 100, :remaining_points => 2_000), false, true).should == {
        :description => "Points are loaded (<a href=\"/schemes/#{user_scheme.scheme.slug}/catalogs\">Test Scheme</a>)",
        :credit => "100",
        :debit => "-",
        :balance => "2,000"
      }
      order_id = "ORD#{order.id}"
      helper.points_summary_for(Fabricate(:scheme_transaction_debit, :points => 200, :remaining_points => 2_000), false, true).should == {
        :description => "Points are redeemed (<a href=\"/orders\">#{order_id}</a>)",
        :credit => "-",
        :debit => "200",
        :balance => "2,000"
      }

      helper.points_summary_for(Fabricate(:scheme_transaction_refund, :points => 300, :remaining_points => 1700), false, true).should == {
        :description => "Points are refunded (<a href=\"/orders\">#{order_id}</a>)",
        :credit => "300",
        :debit => "-",
        :balance => "1,700"
      }
    end

    it "should build points statement description for participant" do
      helper.stub(:current_user).and_return(user)
      helper.summary_description(Fabricate(:scheme_transaction), false, true).should == "Points are loaded (<a href=\"/schemes/#{user_scheme.scheme.slug}/catalogs\">Test Scheme</a>)"
      order_id = "ORD#{order.id}"
      helper.summary_description(Fabricate(:scheme_transaction_debit, :transaction => order), false, true).should == "Points are redeemed (<a href=\"/orders\">#{order_id}</a>)"
      helper.summary_description(Fabricate(:scheme_transaction_refund, :transaction => order_item.order), false, true).should == "Points are refunded (<a href=\"/orders\">#{order_id}</a>)"
    end

    it "should build points statement description for admin" do
      helper.stub(:current_user).and_return(user)
      helper.summary_description(Fabricate(:scheme_transaction), true, true).should == "Points are loaded (<a href=\"/admin/schemes\">Test Scheme</a>)"
      order_id = "ORD#{order.id}"
      helper.summary_description(Fabricate(:scheme_transaction_debit, :transaction => order), true, true).should == "Points are redeemed (<a href=\"/admin/order_items\">#{order_id}</a>)"
      helper.summary_description(Fabricate(:scheme_transaction_refund, :transaction => order_item.order), true, true).should == "Points are refunded (<a href=\"/admin/order_items\">#{order_id}</a>)"
    end

    it "should build points statement description for admin reports" do
      helper.stub(:current_user).and_return(user)
      helper.summary_description(Fabricate(:scheme_transaction), false, false).should == 'Points are loaded (Test Scheme)'
      order_id = "ORD#{order.id}"
      helper.summary_description(Fabricate(:scheme_transaction_debit, :transaction => order), false, false).should == "Points are redeemed (#{order_id})"
      helper.summary_description(Fabricate(:scheme_transaction_refund, :transaction => order_item.order), false, false).should == "Points are refunded (#{order_id})"
    end

  end
  
end
