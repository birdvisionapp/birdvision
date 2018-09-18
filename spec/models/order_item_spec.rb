require "spec_helper"

describe OrderItem do
  it { should belong_to :client_item }
  it { should belong_to :order }
  it { should belong_to :supplier }
  it { should allow_mass_assignment_of :order }
  it { should allow_mass_assignment_of :client_item }
  it { should allow_mass_assignment_of :quantity }
  it { should allow_mass_assignment_of :shipping_agent }
  it { should allow_mass_assignment_of :shipping_code }
  it { should allow_mass_assignment_of :supplier_id }
  it { should_not allow_mass_assignment_of :status }
  it { should respond_to(:versions) }
  it { should respond_to(:scheme) }
  it { should respond_to(:sent_to_supplier_date) }
  it { should respond_to(:sent_for_delivery) }
  it { should respond_to(:points_claimed) }
  it { should respond_to(:price_in_rupees) }
  it { should respond_to(:bvc_margin) }
  it { should respond_to(:bvc_price) }
  it { should respond_to(:channel_price) }
  it { should respond_to(:mrp) }
  it { should be_trailed }

  context "client" do
    it "should return all order items for given client" do
      scheme = Fabricate(:scheme)
      order_item1 = Fabricate(:order_item, :scheme => scheme)
      order_item2 = Fabricate(:order_item, :scheme => scheme)
      order_item3 = Fabricate(:order_item, :scheme => scheme)
      Fabricate(:order_item)

      OrderItem.for_client(scheme.client.id).should == [order_item1, order_item2, order_item3]
    end
  end

  context "scopes" do
    it "should return new orders" do
      new_order_item = Fabricate(:order_item, :status => :new)
      OrderItem.new_orders.should == [new_order_item]
    end
    it "should return sent to supplier orders" do
      sent_to_supplier_order_item = Fabricate(:order_item, :status => :sent_to_supplier)
      OrderItem.sent_to_supplier.should == [sent_to_supplier_order_item]
    end
    it "should return delivery in progress orders" do
      delivery_in_progress_order_item = Fabricate(:order_item, :status => :delivery_in_progress)
      OrderItem.delivery_in_progress.should == [delivery_in_progress_order_item]
    end
    it "should return sent to delivered orders" do
      delivered_order_item = Fabricate(:order_item, :status => :delivered)
      OrderItem.delivered.should == [delivered_order_item]
    end
    it "should return sent to incorrect orders" do
      incorrect_order_item = Fabricate(:order_item, :status => :incorrect)
      OrderItem.incorrect.should == [incorrect_order_item]
    end

    it "should return only valid orders" do
      new_order_item = Fabricate(:order_item, :status => :new)
      incorrect_order_item = Fabricate(:order_item, :status => :incorrect)
      delivered_order_item = Fabricate(:order_item, :status => :delivered)
      OrderItem.valid_orders.should_not include(incorrect_order_item)
      OrderItem.valid_orders.should include(delivered_order_item, new_order_item)
    end

    it "should return only orders created within date range" do
      old_order_item = Fabricate(:order_item, :created_at => 3.days.ago)
      current_order_item = Fabricate(:order_item, :created_at => Date.today)
      new_order_item = Fabricate(:order_item, :created_at => 3.days.from_now)
      range = Date.yesterday..Date.tomorrow
      OrderItem.created_within(range).should_not include(old_order_item, new_order_item)
      OrderItem.valid_orders.should include(current_order_item)
    end
  end

  context "state machine for status" do
    it "should tell that the event is valid" do
      OrderItem.valid_status_event?(:delete).should be_false

      [:send_to_supplier, :send_for_delivery, :deliver, :incorrect, :refund].each do |action|
        OrderItem.valid_status_event?(action).should be_true
      end
    end

    context "new" do
      before(:each) do
        @new_order_item = Fabricate(:order_item, :quantity => 2)
      end

      it "default status of order item should be new" do
        @new_order_item.status.should == 'new'
      end

      it "should be able to transition from new to dispatched to supplier and incorrect state " do
        @new_order_item.status_events.should == [:send_to_supplier, :incorrect]
      end

      it "should be able to dispatch order to supplier after its created" do
        @new_order_item.send_to_supplier
        @new_order_item.reload.status.should == 'sent_to_supplier'
      end

      it "should be able to mark order as incorrect after creation" do
        @new_order_item.incorrect
        @new_order_item.reload.status.should == 'incorrect'
      end
    end

    context "Refund" do
      it "should be able to mark order as refunded if it is incorrect" do
        user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3), :total_points => 10_000, :redeemed_points => 5_000)

        new_order_item = Fabricate(:order_item, :scheme => user_scheme.scheme,
                                   :order => Fabricate(:order, :user => user_scheme.user),
                                   :quantity => 2, :status => :incorrect, :price_in_rupees => 10_000,
                                   :points_claimed => 2_000)
        OrderItemNotifier.should_receive(:notify_refund).with(new_order_item, user_scheme)

        new_order_item.refund
        new_order_item.reload.status.should == 'refunded'
        new_order_item.points_claimed.should == 0
        new_order_item.price_in_rupees.should == 0
        user_scheme.reload.redeemed_points.should == 3_000

      end

      it "should not be able to mark order as refunded if status is not incorrect" do
        new_order_item = Fabricate(:order_item, :quantity => 2, :status => :sent_to_supplier)
        new_order_item.refund
        new_order_item.reload.status.should == 'sent_to_supplier'
      end
    end

    context "sent to supplier" do
      before(:each) do
        @sent_order_item = Fabricate(:order_item, :quantity => 2, :status => :sent_to_supplier)
      end

      it "should be able to transition from dispatch to supplier to delivery in progress and incorrect state" do
        @sent_order_item.status_events.should == [:send_for_delivery, :incorrect]
      end

      it "should be able to mark in progress after order is dispatched" do
        @sent_order_item.send_for_delivery
        @sent_order_item.reload.status.should == 'delivery_in_progress'
      end

      it "should be able to mark order as incorrect after sending it to supplier" do
        @sent_order_item.incorrect
        @sent_order_item.reload.status.should == 'incorrect'
      end

    end

    context "delivery in progress" do
      before(:each) do
        @delivery_in_progress = Fabricate(:order_item, :quantity => 2, :status => :delivery_in_progress)
      end

      it "should be able to transition from delivery in progress to deliver and incorrect state " do
        @delivery_in_progress.status_events.should == [:deliver, :incorrect]
      end

      it "should be deliver an order in progress" do
        @delivery_in_progress.deliver
        @delivery_in_progress.reload.status.should == 'delivered'
      end

      it "should be able to mark order as incorrect after sending it for delivery" do
        @delivery_in_progress.incorrect
        @delivery_in_progress.reload.status.should == 'incorrect'
      end

    end

    context "delivered" do
      before(:each) do
        @delivered_order_item = Fabricate(:order_item, :quantity => 2, :status => :delivered)
      end

      it "delivered should be the final state of order" do
        @delivered_order_item.status_events.should be_empty
      end
    end

  end

  context "time to delivery" do
    it "should calculate hours from placing order if order item is not yet delivered" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 2.hours)
      Timecop.freeze { order_item.time_to_delivery.should == Time.now }
    end

    it "should calculate difference between created and delivered dates if item is already delivered" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 12.hours, :delivered_at => Time.now - 5.hours, :status => :delivered)
      order_item.reload.time_to_delivery.should == order_item.delivered_at
    end

  end

  it "should set delivery date when admin marks order as delivered" do
    order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :delivery_in_progress)
    order_item.deliver

    order_item.reload.delivered_at.should be_present
  end

  context "paper_trail versions" do

    it "should create a version of order if it is updated" do
      order_item = Fabricate(:order_item, :status => :new)

      with_versioning do
        order_item.send_to_supplier
      end

      order_item.versions.count.should == 2
      order_item.versions.first.reify.status.should == :new
      order_item.status.should == :sent_to_supplier.to_s
    end

  end

  context "emails" do
    it "should call OrderItemMailer when the status is changed to delivery_in_progress" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :sent_to_supplier)

      OrderItemNotifier.should_receive(:notify_shipment).with(order_item)

      order_item.send_for_delivery
      order_item.status.should == :delivery_in_progress.to_s
    end

    it "should change the status to delivery in progress even when delivery of email fails" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :sent_to_supplier)

      OrderItemNotifier.should_receive(:notify_shipment).with(order_item).and_raise(Exception)

      Rails.logger.should_receive(:warn).with(/Could not send Shipping confirmation email.*#{order_item.id}.*/)

      order_item.send_for_delivery
      order_item.status.should == :delivery_in_progress.to_s
    end

    it "should call OrderItemMailer when the status is changed to delivered" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :delivery_in_progress)

      OrderItemNotifier.should_receive(:notify_delivery).with(order_item)

      order_item.deliver
      order_item.status.should == :delivered.to_s
    end

    it "should change the status to delivered even when delivery of email fails" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :delivery_in_progress)

      OrderItemNotifier.should_receive(:notify_delivery).with(order_item).and_raise(Exception)

      Rails.logger.should_receive(:warn).with(/Could not send Delivery confirmation email.*#{order_item.id}.*/)

      order_item.deliver
      order_item.status.should == :delivered.to_s
    end

  end

  it "should find parent category of order item" do
    category = Fabricate(:category)
    sub_category = Fabricate(:sub_category_it, :ancestry => category.id)
    client_item = Fabricate(:client_item, :item => Fabricate(:item, :category => sub_category))
    order_item = OrderItem.new(:client_item => client_item, :quantity => 2)
    order_item.parent_category.should =~ /furniture -/
  end

  it "should generate headers for csv of order items download" do
    Fabricate.build(:order_item)
    OrderItem.to_csv.should == "Order ID,Category,Sub Category,Item Id,Item Name,Listing Id,Supplier Name,Quantity,"+
        "Participant Full Name,Participant Username,Recipient name,Address,Landmark,City,Pincode,State,Mobile,Landline," +
        "Client,Scheme,Status,Dispatched To Participant Date,Redeemed At Date,Points,MRP(Rs.),Supplier Margin(%),"+
        "Channel Price(Rs.),Base Price(Rs.),Base Margin(%),Client Price(Rs.),Client Margin(%),Aging Total,Shipping Agent,Shipping Code,Reseller\n"
  end

  it "should return dispatched to participant date for delivery in progress" do
    order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :sent_to_supplier, :quantity => 1,
                           :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000)
    mailer = mock("mailer")
    OrderItemMailer.should_receive(:shipped).with(instance_of(OrderItem), order_item.points_claimed).and_return(mailer)
    mailer.stub(:deliver)
    Timecop.freeze {
      order_item.send_for_delivery
      order_item.dispatched_to_participant_date.to_s.should include(order_item.updated_at.to_s)
    }
    order_item1 = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :sent_to_supplier, :quantity => 1,
                            :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000)
    order_item1.dispatched_to_participant_date.should == ""
  end

  context "utility methods" do
    it "tracking_info_updatable? should return true if order is in sent_to_supplier or delivery_in_progress status" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => 'sent_to_supplier')
      order_item.tracking_info_updatable?.should == true
    end

    it "tracking_info_updatable? should return false if order is not in sent_to_supplier or delivery_in_progress status" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => 'new')
      order_item.tracking_info_updatable?.should == false
    end

    it "should calculate supplier margin for the item of that order item" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => 'new', :mrp => 100, :channel_price => 80)
      order_item.supplier_margin.should == 20
    end

    it "should determine if order_item is not in refunded state" do
      order_item = Fabricate(:order_item, :status => "new")
      order_item.not_refunded?.should == true
    end

    it "should determine if order_item is in refunded state" do
      order_item = Fabricate(:order_item, :status => "refunded")
      order_item.not_refunded?.should == false
    end

  end

  context "Time of status change" do
    it "should record time of status change of an order item" do
      order_item = Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :new)
      Timecop.freeze {
        order_item.send_to_supplier
        order_item.sent_to_supplier_date.should == Time.now
      }
      Timecop.freeze {
        order_item.send_for_delivery
        order_item.sent_for_delivery.should == Time.now
      }
      Timecop.freeze {
        order_item.deliver
        order_item.delivered_at.should == Time.now
      }
    end
  end

  context "reseller" do

    it "should return reseller name if client of te order has a reseller assigned" do
      scheme = Fabricate(:scheme)
      order = Fabricate(:order, :user => Fabricate(:user, :client => scheme.client))
      order_item = Fabricate(:order_item, :scheme => scheme, :order => order)
      order_item1 = Fabricate(:order_item, :scheme => scheme, :created_at => Date.tomorrow, :order => order)
      order_item2 = Fabricate(:order_item, :scheme => scheme, :created_at => Date.tomorrow + 1.day, :order => order)
      client_reseller = Fabricate(:client_reseller, :client => scheme.client, :payout_start_date => Date.tomorrow)
      order_item.reseller_name.should == ""
      order_item1.reseller_name.should == client_reseller.reseller.name
      order_item2.reseller_name.should == client_reseller.reseller.name
    end
  end

  it "should return order items for given user_scheme" do
    scheme = Fabricate(:scheme)
    user_scheme = Fabricate(:user_scheme, :scheme => scheme)
    user_scheme2 = Fabricate(:user_scheme, :scheme => scheme)
    order_item1 = Fabricate(:order_item, :scheme => scheme, :order => Fabricate(:order, :user => user_scheme.user), :price_in_rupees => 200)
    order_item2 = Fabricate(:order_item, :scheme => scheme, :order => Fabricate(:order, :user => user_scheme2.user), :price_in_rupees => 5_000)

    OrderItem.for_user_scheme(user_scheme).should == [order_item1]
  end
end
