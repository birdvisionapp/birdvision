require 'spec_helper'

describe OrdersHelper do
  it "should return participant friendly status of an order " do
    humanize_order_status(:new).should == "Order Confirmed"
    humanize_order_status(:sent_to_supplier).should == "Order Confirmed"
    humanize_order_status(:delivery_in_progress).should == "Shipped"
    humanize_order_status(:delivered).should == "Delivery Confirmed"
    humanize_order_status(:incorrect).should == "Cancelled"
  end

end

