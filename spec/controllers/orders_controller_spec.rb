require "spec_helper"

describe OrdersController do
  login_user

  context "routes" do
    it "should route requests correctly" do
      {:get => order_index_path}.should route_to('orders#index')
      {:get => new_order_path(:scheme_slug => 'some-scheme_slug')}.should route_to('orders#new', :scheme_slug => 'some-scheme_slug')
      {:get => order_path(:id => 1, :scheme_slug => 'some-scheme_slug')}.should route_to('orders#show', :id => "1", :scheme_slug => 'some-scheme_slug')
      {:post => create_preview_path(:scheme_slug => 'some-scheme_slug')}.should route_to('orders#create_preview', :scheme_slug => 'some-scheme_slug')
      {:get => order_preview_path(:scheme_slug => 'some-scheme_slug')}.should route_to('orders#preview', :scheme_slug => 'some-scheme_slug')
      {:post => orders_path(:scheme_slug => 'some-scheme_slug')}.should route_to('orders#create', :scheme_slug => 'some-scheme_slug')
      {:post => send_otp_path(:scheme_slug => 'some-scheme_slug')}.should route_to('orders#send_otp', :scheme_slug => 'some-scheme_slug')
    end
  end

  context "new order" do
    let!(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }
    let(:scheme) { Fabricate(:scheme, :client => @user.client) }

    it "should render form with proposed order details" do
      Fabricate(:cart_item, :cart => user_scheme.cart)

      get :new, :scheme_slug => scheme.slug
      assigns(:order).should_not be_nil
      assigns(:order).order_items.size.should == 1
      response.should be_ok
    end

    it "should redirect to carts page if user has less points" do
      client_item = Fabricate(:client_item, :client_price => 10_00_000)
      Fabricate(:cart_item, :client_item => client_item, :cart => user_scheme.cart)
      Fabricate(:cart_item, :client_item => client_item, :cart => user_scheme.cart)

      get :new, :scheme_slug => scheme.slug

      response.should redirect_to carts_path
    end

    it "should redirect to cart page if cart empty" do
      get :new, :scheme_slug => scheme.slug

      response.should redirect_to carts_path
    end
  end

  context "create order" do
    let(:scheme) { Fabricate(:scheme, :client => @user.client) }
    let!(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }

    let(:valid_order_params) {
      {:address_name => "Tester", :address_body => "Yerwada",
       :address_city => "Pune", :address_state => "MH",
       :address_zip_code => "411006", :address_phone => "7798987102",
       :address_landmark => ""}
    }
    it "should redirect to order confirmation when order is saved" do
      user_scheme.cart.add_client_item(Fabricate(:client_item, :client_price => 4000))
      session[:order] = valid_order_params
      post :create, :scheme_slug => scheme.slug
      response.should redirect_to order_path(:id => Order.first, :scheme_slug => scheme.slug)
      flash[:notice].should == "Thank you for your order"
      @user.orders.count.should == 1
      @user.orders.first.address_city.should == "Pune"
      @user.orders.first.order_items.size.should == 1
    end

    it "should render new if errors in order" do #unlikely but can happen if we add additional validations..
      user_scheme.cart.add_client_item(Fabricate(:client_item, :client_price => 4000))
      session[:order] = {:address_name => "", :address_body => "",
                         :address_city => "", :address_state => "",
                         :address_zip_code => "", :address_phone => "",
                         :address_landmark => ""}
      post :create, :scheme_slug => scheme.slug
      response.should redirect_to(carts_path)
    end

    it "should render new if no schemes are currently active" do
      user_scheme.cart.add_client_item(Fabricate(:client_item, :client_price => 4000))
      scheme = Fabricate(:expired_scheme, :name => "Expired scheme", :client => @user.client)
      Fabricate(:user_scheme, :scheme => scheme, :user => @user)
      session[:order] = valid_order_params

      post :create, :scheme_slug => scheme.slug
      response.should redirect_to(carts_path)
    end

    it "should send order confirmation notification" do
      user_scheme.cart.add_client_item(Fabricate(:client_item, :client_price => 4000))
      OrderNotifier.should_receive(:notify_confirmation).with(instance_of(Order), instance_of(UserScheme))
      session[:order] = valid_order_params

      post :create, :scheme_slug => scheme.slug

    end

    it "should clear session state on order creation" do
      user_scheme.cart.add_client_item(Fabricate(:client_item, :client_price => 4000))
      session[:order] = valid_order_params
      post :create, :scheme_slug => scheme.slug
      session[:order].should be_nil
    end

    it "should not place order if user points are less than cart points" do
      user_scheme.cart.add_client_item(Fabricate(:client_item, :client_price => 14_00_000))
      session[:order] = valid_order_params
      post :create, :scheme_slug => scheme.slug
      response.should redirect_to carts_path
      @user.orders.count.should == 0
    end
  end

  context "preview order" do
    let(:scheme) { Fabricate(:scheme, :client => @user.client) }
    let!(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }

    let(:valid_order_params) {
      {:address_name => "Tester", :address_body => "Yerwada",
       :address_city => "Pune", :address_state => "MH",
       :address_zip_code => "411006", :address_phone => "7798987102",
       :address_landmark => ""}
    }

    it "should not create an order" do
      user_scheme.cart.add_client_item(Fabricate(:client_item, :client_price => 4000))
      order_address = valid_order_params

      expect {
        post :create_preview, :order => order_address, :scheme_slug => scheme.slug
      }.to_not change { Order.count }

      session[:order].should == order_address.stringify_keys
      response.should redirect_to(order_preview_path(:scheme_slug => scheme.slug))
    end

    it "should render order preview page" do
      session[:order] = valid_order_params

      get :preview, :scheme_slug => scheme.slug

      assigns[:order].address_name.should == valid_order_params[:address_name]
    end

    it "should render new if errors in order" do
      post :create_preview, {:scheme_slug => scheme.slug,
                             :order => {:address_name => "", :address_body => "",
                                        :address_city => "", :address_state => "",
                                        :address_zip_code => "", :address_phone => "",
                                        :address_landmark => ""}}
      response.should render_template :new
    end
  end


  context "send one time password" do
    let(:scheme) { Fabricate(:scheme, :client => @user.client) }
    let!(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }

    let(:valid_order_params) {
      {:address_name => "Tester", :address_body => "Yerwada",
       :address_city => "Pune", :address_state => "MH",
       :address_zip_code => "411006", :address_phone => "7798987102",
       :address_landmark => ""}
    }

    it "should send one time password after filling shipping details and render order preview page" do
      @user.client.allow_otp = true
      @user.client.allow_otp_email = true
      @user.client.save
      post :create_preview, {:scheme_slug => scheme.slug, :order => valid_order_params}
      response.should redirect_to(order_preview_path(:scheme_slug => scheme.slug))
    end

    it "should fail to send one time password again and render order preview page" do
      post :send_otp, {:scheme_slug => scheme.slug}
      response.should redirect_to(order_preview_path(:scheme_slug => scheme.slug))
      flash[:alert].should == "The One Time Password (OTP) is not enabled for #{@user.client.client_name}"
    end

    it "should send one time password again and render order preview page" do
      @user.client = Fabricate(:client_allow_otp)
      @user.save
      post :send_otp, {:scheme_slug => scheme.slug}
      response.should redirect_to(order_preview_path(:scheme_slug => scheme.slug))
      flash[:notice].should == "The One Time Password (OTP) has been sent to your registered Email/Mobile number"
    end

    it "should not place order if one time password is not entered by user" do
      @user.client = Fabricate(:client_allow_otp)
      @user.save
      session[:order] = valid_order_params
      post :create, :scheme_slug => scheme.slug, :user => {:otp => ''}
      response.should redirect_to order_preview_path(:scheme_slug => scheme.slug)
      flash[:alert].should == "Please enter the One Time Password (OTP) which was sent to your Email/Mobile number"
    end

    it "should not place order if invalid one time password is entered by user" do
      @user.client = Fabricate(:client_allow_otp)
      @user.save
      session[:order] = valid_order_params
      post :create, :scheme_slug => scheme.slug, :user => {:otp => '123456'}
      response.should redirect_to order_preview_path(:scheme_slug => scheme.slug)
      flash[:alert].should == "The One Time Password (OTP) entered by you is Incorrect, hence your order cannot be processed."
    end

    it "should redirect to order confirmation when valid one time password is entered by user" do
      @user.client = Fabricate(:client_allow_otp)
      @user.save
      user_scheme.cart.add_client_item(Fabricate(:client_item, :client_price => 4000))
      session[:order] = valid_order_params
      post :create, :scheme_slug => scheme.slug, :user => {:otp => @user.otp_code}
      response.should redirect_to order_path(:id => Order.first, :scheme_slug => scheme.slug)
      flash[:notice].should == "Thank you for your order"
      @user.orders.count.should == 1
      @user.orders.first.address_city.should == "Pune"
      @user.orders.first.order_items.size.should == 1
    end

  end

  context "show order" do
    let(:scheme) { Fabricate(:scheme, :client => @user.client) }
    let!(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }

    it "should show order" do
      order = Fabricate(:order, :user => @user)
      get :show, :id => order.id, :scheme_slug => scheme.slug
      response.should be_ok
      response.should render_template :show
    end

    it "should throw error if try to access order of other user" do
      client = Fabricate(:client, :client_name => "client")
      order = Fabricate(:order, :user => Fabricate(:user, :participant_id => "123"))
      expect {
        get :show, :id => order.id, :scheme_slug => scheme.slug
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "should throw error if order does not exist" do
      expect {
        get :show, :id => rand(max=10), :scheme_slug => scheme.slug
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "orders list" do
    let(:scheme) { Fabricate(:scheme, :client => @user.client) }
    let!(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }

    it "should list all the orders for the user" do
      order1 = Fabricate(:order, :order_items => [Fabricate(:order_item)], :user => @user)
      order2 = Fabricate(:order, :order_items => [Fabricate(:order_item)], :user => @user)

      get :index, :scheme_slug => scheme.slug

      assigns[:orders].should == [order2, order1] #tests desc order as well :)
      response.should render_template :index
      response.should be_success
    end

    it "should paginate results" do
      with_pagination_override(Order, 1) do
        orders = 2.times.collect { Fabricate(:order, :order_items => [Fabricate(:order_item)], :user => @user) }

        get :index, :page => 2, :scheme_slug => scheme.slug

        assigns[:orders].should == [orders[0]]
      end
    end

  end
end

