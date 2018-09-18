require "spec_helper"

describe OrderMailer do
  context 'mail' do
    before(:each) do
      @user = Fabricate(:user, :email => 'user@me.com')
      @user.client.update_attributes!(:points_to_rupee_ratio => 1)
    end
    context "point based" do
      it 'should send email for the order' do
        order = Fabricate(:order, :user => @user)
        Fabricate(:order_item, :order => order, :client_item => Fabricate(:client_item, :client_price => 30), :quantity => 3, :points_claimed => 1500)
        scheme = order.reload.order_items.first.scheme
        OrderMailer.any_instance.should_receive(:sendgrid_category).with('Participant Order Confirmation')
        OrderMailer.any_instance.should_receive(:sendgrid_unique_args).with(:order => order.order_id, :scheme => scheme.name)

        mail = OrderMailer.point_redemption(order, scheme, order.order_items, order.total)

        mail.should deliver_to(@user.email)
        mail.should deliver_from("no-reply@birdvision.in")
        mail.should have_subject("#{@user.client.client_name} Rewards Program - Order Confirmation")

        mail.should have_body_text("Dear #{@user.full_name}")

        mail.should have_body_text("Thank you for your Order #{order.order_id} which has been successfully confirmed.")
        mail.should have_body_text("This email contains your Order Summary. When the Item(s) in your Order are shipped, you will receive an email with a Tracking ID with which you can track your order.")
        mail.should have_body_text("You can also check the status of your order on your ")
        
        mail.should have_link("My Orders", :href => order_index_url)
        
        mail.should have_body_text("Please find below the summary of your Order: #{order.order_id}")

        mail.should have_body_text("Title")
        mail.should have_body_text(order.order_items.first.client_item.item.title)
        mail.should have_body_text("Points")
        mail.should have_body_text("500")
        mail.should have_body_text("Quantity")
        mail.should have_body_text("3")
        mail.should have_body_text("Sub Total")
        mail.should have_body_text("1500")

        mail.should have_body_text("Grand Total: 1500 pts")
        mail.should have_body_text("Your order will be delivered in approximately 15 working days")
        mail.should have_link("Contact Us", :href => "http://localhost/contact_us")
      end
    end
  end
  context "single redemption" do
    before(:each) do
      @user = Fabricate(:user, :email => 'user@me.com')
      @user.client.update_attributes!(:points_to_rupee_ratio => 1)
      @order = Fabricate(:order, :user => @user)
      @client_catalog = Fabricate(:client_catalog, :client => @user.client)
      @scheme = Fabricate(:scheme, :single_redemption => true, :client => @user.client)
      Fabricate(:user_scheme, :user => @user, :scheme => @scheme)
    end

    it 'should send email for the order' do

      Fabricate(:order_item, :order => @order, :client_item => Fabricate(:client_item, :client_price => 123456, :client_catalog => @client_catalog),
        :quantity => 3, :points_claimed => 1500, :scheme => @scheme)

      OrderMailer.any_instance.should_receive(:sendgrid_category).with('Participant Order Confirmation')
      OrderMailer.any_instance.should_receive(:sendgrid_unique_args).with(:order => @order.order_id, :scheme => @scheme.name)

      mail = OrderMailer.point_redemption(@order, @scheme, @order.order_items, @order.total)

      mail.should deliver_to(@user.email)
      mail.should deliver_from("no-reply@birdvision.in")
      mail.should have_subject("#{@user.client.client_name} Rewards Program - Order Confirmation")

      mail.should have_body_text("Dear #{@user.full_name}")

      mail.should have_body_text("Thank you for your Order #{@order.order_id} which has been successfully confirmed.")
      mail.should have_body_text("This email contains your Order Summary. When the Item(s) in your Order are shipped, you will receive an email with a Tracking ID with which you can track your order.")
      mail.should have_body_text("You can also check the status of your order on your ")

      mail.should have_link("My Orders", :href => order_index_url)

      mail.should have_body_text("Please find below the summary of your Order: #{@order.order_id}")

      mail.should have_body_text("Title")
      mail.should have_body_text(@order.order_items.first.client_item.item.title)
      mail.should have_body_text("Quantity")
      mail.should have_body_text("3")
      mail.should have_body_text("Your order will be delivered in approximately 15 working days")
      mail.should have_link("Contact Us", :href => "http://localhost/contact_us")
    end
  end

end
