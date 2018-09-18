require "spec_helper"

describe OrderItemMailer do

  context "order item mailer - point based" do

    before(:each) do
      @user = Fabricate(:user, :email => 'user@me.com')
      @user.client.update_attributes!(:points_to_rupee_ratio => 1)
      @order = Fabricate(:order, :user => @user)
      @order_item = Fabricate(:order_item, :order => @order, :quantity => 3, :shipping_agent => "DHL", :shipping_code => "1234", :points_claimed => "1500")
    end

    it 'should send email to user when order item is dispatched to supplier' do
      OrderItemMailer.any_instance.should_receive(:sendgrid_category).with('Participant Order Shipment')
      OrderItemMailer.any_instance.should_receive(:sendgrid_unique_args).with(:order => @order_item.order.order_id, :scheme => @order_item.scheme.name, :order_item => @order_item.id)

      mail = OrderItemMailer.shipped @order_item, @order_item.points_claimed

      mail.should deliver_to(@user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{@order.user.client.client_name} Rewards Program - Shipment of Item in Order #{@order.order_id}")

      mail.should have_body_text("Dear #{@user.full_name}")
      mail.should have_body_text("We are pleased to inform you that we have shipped the following item in your Order: #{@order.order_id}")

      mail.should have_body_text("You can track your Order on DHL's website with the tracking number")

      mail.should have_body_text("Title")
      mail.should have_body_text(@order_item.client_item.item.title)
      mail.should have_body_text("Points")
      mail.should have_body_text("500")
      mail.should have_body_text("Quantity")
      mail.should have_body_text("3")
      mail.should have_body_text("Sub Total")
      mail.should have_body_text("1500")

      mail.should have_body_text("The shipment was sent to:")
      mail.should have_body_text(@order_item.order.address_name)
    end

    it "should send mail when order delivered" do
      OrderItemMailer.any_instance.should_receive(:sendgrid_category).with('Participant Order Delivery')
      OrderItemMailer.any_instance.should_receive(:sendgrid_unique_args).with(:order => @order_item.order.order_id, :scheme => @order_item.scheme.name, :order_item => @order_item.id)

      mail = OrderItemMailer.delivered @order_item, @order_item.points_claimed

      mail.should deliver_to(@user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{@order.user.client.client_name} Rewards Program - Delivery of item in Order #{@order.order_id}")

      mail.should have_body_text("Dear #{@user.full_name}")
      mail.should have_body_text("We are pleased to confirm delivery of the following Item in your Order: #{@order.order_id}")

      mail.should have_body_text("Title")
      mail.should have_body_text(@order_item.client_item.item.title)
      mail.should have_body_text("Points")
      mail.should have_body_text("500")
      mail.should have_body_text("Quantity")
      mail.should have_body_text("3")
      mail.should have_body_text("Sub Total")
      mail.should have_body_text("1500")

      mail.should have_body_text("The order was delivered to:")
      mail.should have_body_text(@order_item.order.address_name)
    end

    it "should send mail when order item is refunded if show points" do
      OrderItemMailer.any_instance.should_receive(:sendgrid_category).with('Participant Order Refund')
      OrderItemMailer.any_instance.should_receive(:sendgrid_unique_args).with(:order => @order_item.order.order_id, :scheme => @order_item.scheme.name, :order_item => @order_item.id)

      mail = OrderItemMailer.refunded @order_item, @order_item.points_claimed

      mail.should deliver_to(@user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{@order.user.client.client_name} Rewards Program - Refund of item in Order #{@order.order_id}")

      mail.should have_body_text("Dear #{@user.full_name}")
      mail.should have_body_text("Your Order: #{@order.order_id} for #{@order_item.client_item.item.title} has been successfully refunded")

      mail.should have_body_text("Please find the summary below:")
      
      mail.should have_body_text("Title")
      mail.should have_body_text(@order_item.client_item.item.title)
      mail.should have_body_text("Points")
      mail.should have_body_text("500")
      mail.should have_body_text("Quantity")
      mail.should have_body_text("3")
      mail.should have_body_text("Sub Total")
      mail.should have_body_text("1500")
    end
  end

  context "order item mailer - single redemption" do

    before(:each) do
      @user = Fabricate(:user, :email => 'user@me.com')
      @user.client.update_attributes!(:points_to_rupee_ratio => 1)
      @order = Fabricate(:order, :user => @user)
      @order_item = Fabricate(:order_item, :order => @order, :scheme => Fabricate(:scheme, :single_redemption => true), :quantity => 3, :shipping_agent => "DHL", :shipping_code => "1234", :points_claimed => "1000")
    end

    it 'should send email to user when order item is dispatched to supplier' do
      OrderItemMailer.any_instance.should_receive(:sendgrid_category).with('Participant Order Shipment')
      OrderItemMailer.any_instance.should_receive(:sendgrid_unique_args).with(:order => @order_item.order.order_id, :scheme => @order_item.scheme.name, :order_item => @order_item.id)

      mail = OrderItemMailer.shipped @order_item, @order_item.points_claimed

      mail.should deliver_to(@user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{@order.user.client.client_name} Rewards Program - Shipment of Item in Order #{@order.order_id}")

      mail.should have_body_text("Dear #{@user.full_name}")
      mail.should have_body_text("We are pleased to inform you that we have shipped the following item in your Order: #{@order.order_id}")

      mail.should have_body_text("You can track your Order on DHL's website with the tracking number")

      mail.should have_body_text("Title")
      mail.should have_body_text(@order_item.client_item.item.title)
      mail.should have_body_text("Quantity")
      mail.should have_body_text("3")
      
      mail.should have_body_text("The shipment was sent to:")
      mail.should have_body_text(@order_item.order.address_name)
    end

    it "should send mail when order delivered" do
      OrderItemMailer.any_instance.should_receive(:sendgrid_category).with('Participant Order Delivery')
      OrderItemMailer.any_instance.should_receive(:sendgrid_unique_args).with(:order => @order_item.order.order_id, :scheme => @order_item.scheme.name, :order_item => @order_item.id)

      mail = OrderItemMailer.delivered @order_item, @order_item.points_claimed

      mail.should deliver_to(@user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{@order.user.client.client_name} Rewards Program - Delivery of item in Order #{@order.order_id}")

      mail.should have_body_text("Dear #{@user.full_name}")
      mail.should have_body_text("We are pleased to confirm delivery of the following Item in your Order: #{@order.order_id}")

      mail.should have_body_text("Title")
      mail.should have_body_text(@order_item.client_item.item.title)
      mail.should have_body_text("Quantity")
      mail.should have_body_text("3")

      mail.should have_body_text("The order was delivered to:")
      mail.should have_body_text(@order_item.order.address_name)
    end

    it "should send mail when order item is refunded if show points" do
      OrderItemMailer.any_instance.should_receive(:sendgrid_category).with('Participant Order Refund')
      OrderItemMailer.any_instance.should_receive(:sendgrid_unique_args).with(:order => @order_item.order.order_id, :scheme => @order_item.scheme.name, :order_item => @order_item.id)

      mail = OrderItemMailer.refunded @order_item, @order_item.points_claimed

      mail.should deliver_to(@user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{@order.user.client.client_name} Rewards Program - Refund of item in Order #{@order.order_id}")

      mail.should have_body_text("Dear #{@user.full_name}")
      mail.should have_body_text("Your Order: #{@order.order_id} for #{@order_item.client_item.item.title} has been successfully refunded")

      mail.should have_body_text("Please find the summary below:")

      mail.should have_body_text("Title")
      mail.should have_body_text(@order_item.client_item.item.title)
      mail.should have_body_text("Quantity")
      mail.should have_body_text("3")
    end

  end

end
