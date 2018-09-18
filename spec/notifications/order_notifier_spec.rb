require 'spec_helper'

describe OrderNotifier do

  before(:each) do
    @mailer = mock('mailer')
    @msg = mock("message")
    @msg.stub_chain(:delay, :deliver)
    OrderMailer.should_receive(:delay).and_return(@mailer)
  end

  it "should send order confirmation email/sms for point based" do
    user = Fabricate(:user)
    user_scheme = Fabricate(:user_scheme, :user => user, :scheme => Fabricate(:scheme))
    order_item = Fabricate(:order_item, :scheme => user_scheme.scheme, :points_claimed => 1_000)

    @mailer.should_receive(:point_redemption).with(order_item.order, user_scheme.scheme, [order_item], order_item.order.total)

    SmsMessage.should_receive(:new).with(:point_order_confirmation, :to => user_scheme.user.mobile_number, :order_id => order_item.order.order_id, :total_points => 1_000, :client => user_scheme.user.client.client_name).and_return(@msg)

    OrderNotifier.notify_confirmation(order_item.order, user_scheme)
  end

  it "should send order confirmation email/sms for single redemption" do
    user = Fabricate(:user)
    user_scheme = Fabricate(:single_redemption_user_scheme, :user => user)
    order_item = Fabricate(:order_item, :scheme => user_scheme.scheme, :points_claimed => 1_000)

    @mailer.should_receive(:point_redemption).with(order_item.order, user_scheme.scheme, [order_item], order_item.order.total)

    SmsMessage.should_receive(:new).with(:club_order_confirmation, :to => user_scheme.user.mobile_number, :order_id => order_item.order.order_id, :client => user_scheme.user.client.client_name).and_return(@msg)

    OrderNotifier.notify_confirmation(order_item.order, user_scheme)
  end
end