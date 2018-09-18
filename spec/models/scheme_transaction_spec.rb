require 'spec_helper'

describe SchemeTransaction do
  
  it { should allow_mass_assignment_of :client_id }
  it { should allow_mass_assignment_of :user_id }
  it { should allow_mass_assignment_of :scheme_id }
  it { should allow_mass_assignment_of :action }
  it { should allow_mass_assignment_of :transaction_type }
  it { should allow_mass_assignment_of :transaction_id }
  it { should allow_mass_assignment_of :points }
  it { should allow_mass_assignment_of :remaining_points }

  it { should belong_to(:client) }
  it { should belong_to(:user) }
  it { should belong_to(:scheme) }
  it { should belong_to(:transaction) }

  it "should create scheme transaction for credit points" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3), :total_points => 10_000)
    scheme_transaction = SchemeTransaction.record(user_scheme.scheme.id, 'credit', user_scheme, user_scheme.total_points)
    scheme_transaction.reload
    scheme_transaction.action == 'credit'
    scheme_transaction.points.should == 10_000
    scheme_transaction.remaining_points.should == 10_000
  end

  it "should create scheme transaction for debit points" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme), :total_points => 10_000, :redeemed_points => 9_000)
    order = Fabricate(:order, :user => user_scheme.user, :points => 1_000)
    scheme_transaction = SchemeTransaction.record(user_scheme.scheme.id, 'debit', order, order.points)
    scheme_transaction.reload
    scheme_transaction.action == 'debit'
    scheme_transaction.points.should == 1_000
    scheme_transaction.remaining_points.should == 1_000
  end

  it "should create scheme transaction for refund points" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme), :total_points => 10_000, :redeemed_points => 5_000)

    order_item = Fabricate(:order_item, :scheme => user_scheme.scheme,
      :order => Fabricate(:order, :user => user_scheme.user, :points => 2_000),
      :quantity => 2, :status => :incorrect, :price_in_rupees => 10_000,
      :points_claimed => 2_000)

    scheme_transaction = SchemeTransaction.record(user_scheme.scheme.id, 'refund', order_item.order, order_item.order.points)
    scheme_transaction.reload
    scheme_transaction.action == 'refund'
    scheme_transaction.points.should == 2_000
    scheme_transaction.remaining_points.should == 5_000
  end

end
