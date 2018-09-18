require 'spec_helper'

describe Admin::SchemeTransactionsController do

  login_admin

  context "routes" do
    it "should route correctly" do
      {:get => admin_scheme_transactions_path}.should route_to('admin/scheme_transactions#index')
    end
  end

  context "browse all point statements" do

    it "should show all points statement and default sorted by creation date desc" do
      t1 = Fabricate(:scheme_transaction)
      t2 = Fabricate(:scheme_transaction_debit)
      t3 = Fabricate(:scheme_transaction_refund)
      t4 = Fabricate(:scheme_transaction)
      get :index
      assigns[:scheme_transactions].should == [t4, t3, t2, t1]
      response.should be_success
    end

    it "should paginate results" do
      with_pagination_override(SchemeTransaction, 1) do
        scheme_transactions = 2.times.collect { Fabricate(:scheme_transaction) }
        get :index, :page => 2
        assigns[:scheme_transactions].should == [scheme_transactions[0]]
        response.should be_success
      end
    end

    it "should download the csv report" do
      Fabricate(:user_scheme, :scheme => Fabricate(:scheme), :total_points => 10_000, :redeemed_points => 9_000)
      get :index, :format => :csv
      response.should be_success
      response.body.lines.count.should == 2
      response.body.should include "10,000"
    end

  end
    
  context "filter by client" do
    it "should filter by client when client_id_eq field is selected" do
      client1 = Fabricate(:client)
      client2 = Fabricate(:client)
      t1 = Fabricate(:scheme_transaction, :client => client1)
      t2 = Fabricate(:scheme_transaction_debit, :client => client1)
      t3 = Fabricate(:scheme_transaction, :client => client2)
      get :index, :q => {:client_id_eq => client1.id}
      scheme_transactions = assigns[:scheme_transactions]
      scheme_transactions.should_not include(t3)
      scheme_transactions.length.should == 2
      scheme_transactions.should include(t2, t1)
      response.should be_success
    end

    it "should download csv for filtered results" do
      client1 = Fabricate(:client)
      client2 = Fabricate(:client)
      Fabricate(:user_scheme, :scheme => Fabricate(:scheme, :client => client1), :total_points => 10_000)
      Fabricate(:user_scheme, :scheme => Fabricate(:scheme, :client => client2), :total_points => 5_000)
      order = Fabricate(:order, :points => 1_000)
      Fabricate(:scheme_transaction_debit, :client => client1, :transaction => order)
      get :index, :q => {:client_id_eq => client1.id}, :format => :csv
      response.should be_success
      response.body.lines.count.should == 2
      response.body.should include "100,400"
      response.body.should_not include "5,000"
    end
  end

  context "filter by scheme" do
    it "should filter by scheme when scheme_id_eq field is selected" do
      scheme1 = Fabricate(:scheme)
      scheme2 = Fabricate(:scheme)
      t1 = Fabricate(:scheme_transaction, :scheme => scheme1)
      t2 = Fabricate(:scheme_transaction_debit, :scheme => scheme1)
      t3 = Fabricate(:scheme_transaction, :scheme => scheme2)
      get :index, :q => {:scheme_id_eq => scheme1.id}
      scheme_transactions = assigns[:scheme_transactions]
      scheme_transactions.length.should == 2
      scheme_transactions.should include(t2, t1)
      scheme_transactions.should_not include(t3)
      response.should be_success
    end
  end

  context "filter by created at" do
    before :each do
      @t1 = Fabricate(:scheme_transaction, :created_at => Date.yesterday)
      @t2 = Fabricate(:scheme_transaction, :created_at => Date.today)
      @t3 = Fabricate(:scheme_transaction, :created_at => Time.now)
      @t4 = Fabricate(:scheme_transaction, :created_at => Date.tomorrow)
    end

    it "should filter from start of day when created_at_date_gteq field is given" do
      get :index, :q => {:created_at_date_gteq => Date.today.strftime("%d-%m-%Y")}
      scheme_transactions = assigns[:scheme_transactions]
      scheme_transactions.length.should == 3
      scheme_transactions.should include(@t3, @t2, @t4)
      response.should be_success
    end

    it "should filter before end of day when created_at_date_lteq field is given" do
      get :index, :q => {:created_at_date_lteq => Date.today.strftime("%d-%m-%Y")}
      scheme_transactions = assigns[:scheme_transactions]
      scheme_transactions.length.should == 3
      scheme_transactions.should include(@t3, @t2, @t1)
      response.should be_success
    end

    it "should filter between start of day and end of day when created_at_date_gteq,created_at_date_lteq even when fields are same" do
      get :index, :q => {:created_at_date_gteq => Date.today.strftime("%d-%m-%Y"), :created_at_date_lteq => Date.today.strftime("%d-%m-%Y")}
      scheme_transactions = assigns[:scheme_transactions]
      scheme_transactions.length.should == 2
      scheme_transactions.should include(@t3, @t2)
      response.should be_success
    end
  end

end