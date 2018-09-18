require 'spec_helper'

describe OrderItemNotifier do
  let(:tracked_order_item) { Fabricate(:order_item, :shipping_agent => 'DHL', :shipping_code => '123', :points_claimed => 1_000) }
  let(:untracked_order_item) { Fabricate(:order_item, :shipping_agent => nil, :shipping_code => nil, :quantity => 2, :points_claimed => 1_000) }
  let(:mailer) { mock('mailer') }
  let(:msg) { mock('msg') }

  context "with tracking info" do
    it "should send sms/email for order shipment" do
      mailer.should_receive(:shipped).with(tracked_order_item, tracked_order_item.points_claimed)
      OrderItemMailer.should_receive(:delay).and_return(mailer)
      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:tracked_order_shipment, :to => tracked_order_item.order.user.mobile_number, :order_id => tracked_order_item.order.order_id, :item => tracked_order_item.client_item.item.title, :tracking_info => 'DHL - 123', :client => tracked_order_item.order.user.client.client_name).and_return(msg)

      OrderItemNotifier.notify_shipment(tracked_order_item)
    end

    it "should send sms/email for order delivery" do
      mailer.should_receive(:delivered).with(tracked_order_item, tracked_order_item.points_claimed)
      OrderItemMailer.should_receive(:delay).and_return(mailer)
      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:tracked_order_delivery, :to => tracked_order_item.order.user.mobile_number, :order_id => tracked_order_item.order.order_id, :item => tracked_order_item.client_item.item.title, :tracking_info => 'DHL - 123', :client => tracked_order_item.order.user.client.client_name).and_return(msg)

      OrderItemNotifier.notify_delivery(tracked_order_item)
    end
  end
  context "without tracking info" do
    it "should send sms/email for order shipment" do
      mailer.should_receive(:shipped).with(untracked_order_item, untracked_order_item.points_claimed)
      OrderItemMailer.should_receive(:delay).and_return(mailer)
      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:untracked_order_shipment, :to => untracked_order_item.order.user.mobile_number, :order_id => untracked_order_item.order.order_id, :item => untracked_order_item.client_item.item.title, :client => untracked_order_item.order.user.client.client_name).and_return(msg)

      OrderItemNotifier.notify_shipment(untracked_order_item)
    end

    it "should send sms/email for order delivery" do
      mailer.should_receive(:delivered).with(untracked_order_item, untracked_order_item.points_claimed)
      OrderItemMailer.should_receive(:delay).and_return(mailer)
      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:untracked_order_delivery, :to => untracked_order_item.order.user.mobile_number, :order_id => untracked_order_item.order.order_id, :item => untracked_order_item.client_item.item.title, :client => untracked_order_item.order.user.client.client_name).and_return(msg)

      OrderItemNotifier.notify_delivery(untracked_order_item)
    end
  end

  context "refund" do
    it "should send email/sms for order item refund for non single redemption scheme" do
      mailer.should_receive(:refunded).with(untracked_order_item, untracked_order_item.points_claimed)
      OrderItemMailer.should_receive(:delay).and_return(mailer)
      msg.stub_chain(:delay, :deliver)
      user_scheme = mock("user_scheme")
      user_scheme.stub_chain(:scheme, :show_points?).and_return(true)


      SmsMessage.should_receive(:new).with(:order_item_refund, :to => untracked_order_item.order.user.mobile_number,
        :order_id => untracked_order_item.order.order_id, :item => untracked_order_item.client_item.item.title,
        :points => untracked_order_item.points_claimed, :client => untracked_order_item.order.user.client.client_name).and_return(msg)

      OrderItemNotifier.notify_refund(untracked_order_item, user_scheme)
    end

    it "should send email/sms for order item refund for single redemption scheme" do
      mailer.should_receive(:refunded).with(untracked_order_item, untracked_order_item.points_claimed)
      OrderItemMailer.should_receive(:delay).and_return(mailer)
      msg.stub_chain(:delay, :deliver)
      user_scheme = mock("user_scheme")
      user_scheme.stub_chain(:scheme, :show_points?).and_return(false)


      SmsMessage.should_receive(:new).with(:single_redemption_refund, :to => untracked_order_item.order.user.mobile_number,
        :order_id => untracked_order_item.order.order_id,
        :item => untracked_order_item.client_item.item.title, :client => untracked_order_item.order.user.client.client_name).and_return(msg)

      OrderItemNotifier.notify_refund(untracked_order_item, user_scheme)
    end
  end
end

