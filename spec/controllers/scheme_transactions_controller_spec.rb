require "spec_helper"

describe SchemeTransactionsController do

  login_user

  context "routes" do
    it "should route requests correctly" do
      {:get => points_summary_path}.should route_to('scheme_transactions#index')
    end
  end

  context "scheme transactions list" do
    it "should list all the points transactions for the user default sorted by creation date desc" do
      t1 = Fabricate(:scheme_transaction, :user => @user)
      t2 = Fabricate(:scheme_transaction_debit, :user => @user)
      t3 = Fabricate(:scheme_transaction_refund, :user => @user)
      get :index
      assigns[:point_transactions].should == [t3, t2, t1]
      response.should render_template :index
      response.should be_success
    end

    it "should paginate results" do
      with_pagination_override(SchemeTransaction, 1) do
        point_transactions = 2.times.collect { Fabricate(:scheme_transaction, :user => @user) }
        get :index, :page => 2
        assigns[:point_transactions].should == [point_transactions[0]]
        response.should be_success
      end
    end
  end

  context "filter by scheme" do
    it "should filter by scheme when scheme_id_eq field is selected" do
      scheme1 = Fabricate(:scheme)
      scheme2 = Fabricate(:scheme)
      t1 = Fabricate(:scheme_transaction, :user => @user, :scheme => scheme1)
      t2 = Fabricate(:scheme_transaction_debit, :user => @user, :scheme => scheme1)
      t3 = Fabricate(:scheme_transaction, :user => @user, :scheme => scheme2)
      get :index, :q => {:scheme_id_eq => scheme1.id}
      point_transactions = assigns[:point_transactions]
      point_transactions.length.should == 2
      point_transactions.should include(t2, t1)
      point_transactions.should_not include(t3)
      response.should be_success
    end
  end

  context "filter by created at" do
    before :each do
      @t1 = Fabricate(:scheme_transaction, :user => @user, :created_at => Date.yesterday)
      @t2 = Fabricate(:scheme_transaction, :user => @user, :created_at => Date.today)
      @t3 = Fabricate(:scheme_transaction, :user => @user, :created_at => Time.now)
      @t4 = Fabricate(:scheme_transaction, :user => @user, :created_at => Date.tomorrow)
    end

    it "should filter from start of day when created_at_date_gteq field is given" do
      get :index, :q => {:created_at_date_gteq => Date.today.strftime("%d-%m-%Y")}
      point_transactions = assigns[:point_transactions]
      point_transactions.length.should == 3
      point_transactions.should include(@t3, @t2, @t4)
      response.should be_success
    end

    it "should filter before end of day when created_at_date_lteq field is given" do
      get :index, :q => {:created_at_date_lteq => Date.today.strftime("%d-%m-%Y")}
      point_transactions = assigns[:point_transactions]
      point_transactions.length.should == 3
      point_transactions.should include(@t3, @t2, @t1)
      response.should be_success
    end

    it "should filter between start of day and end of day when created_at_date_gteq,created_at_date_lteq even when fields are same" do
      get :index, :q => {:created_at_date_gteq => Date.today.strftime("%d-%m-%Y"), :created_at_date_lteq => Date.today.strftime("%d-%m-%Y")}
      point_transactions = assigns[:point_transactions]
      point_transactions.length.should == 2
      point_transactions.should include(@t3, @t2)
      response.should be_success
    end
  end 

end

