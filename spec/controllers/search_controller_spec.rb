require 'spec_helper'

describe SearchController do
  login_user

  before(:each) do
    Sunspot.remove_all!
  end

  let(:scheme) { Fabricate(:scheme, :client => @user.client) }
  let!(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }

  it "routes" do
    {:get => search_catalog_path(:scheme_slug => scheme.slug)}.should route_to('search#search_catalog', :scheme_slug => scheme.slug)
  end

  it "should render search results" do

    mobile = Fabricate(:client_item, :item => Fabricate(:item, :title => "mobile"), :client_catalog => @user.client.client_catalog)
    scheme.client_items = [mobile]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)

    Sunspot.index! mobile

    get :search_catalog, {:search => {:keyword => 'mobile'}, :scheme_slug => scheme.slug}

    response.should be_ok
    assigns[:results].should == [mobile]
    assigns[:total_count].should == 1
    response.should render_template(:show)
  end

  it "should render search results for prefix matches" do
    headphones = Fabricate(:client_item, :item => Fabricate(:item, :title => "headphones"), :client_catalog => @user.client.client_catalog)
    scheme.client_items = [headphones]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
    
    Sunspot.index! headphones

    get :search_catalog, {:search => {:keyword => 'head'}, :scheme_slug => scheme.slug}

    response.should be_ok
    assigns[:results].should == [headphones]
    assigns[:total_count].should == 1
    response.should render_template(:show)
  end

  it "should give precedence to title and sort by points asc if precedence by title match" do
    electronics = Fabricate(:category, :title => "Electronics")
    headphones = Fabricate(:client_item, :client_price => 9_000, :item => Fabricate(:item, :title => "headphones", :category => electronics), :client_catalog => @user.client.client_catalog)
    camera = Fabricate(:client_item, :client_price => 8_000, :item => Fabricate(:item, :title => "Camera", :category => electronics), :client_catalog => @user.client.client_catalog)
    handycam = Fabricate(:client_item, :client_price => 30_000, :item => Fabricate(:item, :title => "Camera", :category => electronics), :client_catalog => @user.client.client_catalog)

    scheme.client_items = [camera, headphones, handycam]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
    
    Sunspot.index! ClientItem.all
    get :search_catalog, {"search" => {"category" => "Electronics"}, :scheme_slug => scheme.slug}

    assigns[:results].should == [camera, headphones, handycam]
  end

  it "should render search results for suffix matches" do
    headphones = Fabricate(:client_item, :item => Fabricate(:item, :title => "headphones"), :client_catalog => @user.client.client_catalog)
    scheme.client_items = [headphones]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
    
    Sunspot.index! headphones

    get :search_catalog, {:search => {:keyword => 'phones'}, :scheme_slug => scheme.slug}

    response.should be_ok
    assigns[:results].should == [headphones]
    assigns[:total_count].should == 1
    response.should render_template(:show)
  end

  it "should render search results for filter by points" do
    mobile = Fabricate(:client_item, :client_price => 10_000, :item => Fabricate(:item, :title => "mobile"), :client_catalog => @user.client.client_catalog)
    camera = Fabricate(:client_item, :client_price => 20_000, :item => Fabricate(:item, :title => "Camera"), :client_catalog => @user.client.client_catalog)
    handycam = Fabricate(:client_item, :client_price => 30_000, :item => Fabricate(:item, :title => "Camera"), :client_catalog => @user.client.client_catalog)
    scheme.client_items = [mobile, camera, handycam]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
    
    Sunspot.index! ClientItem.all

    get :search_catalog, {"search" => {"category" => "", "point_range_min" => "200000", "point_range_max" => "300000"}, :scheme_slug => scheme.slug}

    response.should be_ok
    assigns[:results].should == [camera, handycam]
    assigns[:total_count].should == 2
    assigns[:point_range].should == {"min" => 100000, "max" => 300000, "selected_min" => 200000, "selected_max" => 300000}
    response.should render_template(:show)
  end

  it "should fetch price stats" do
    mobile1 = Fabricate(:client_item, :item => Fabricate(:item, :title => "mobile1"), :client_price => 4_000, :client_catalog => @user.client.client_catalog)
    mobile2 = Fabricate(:client_item, :item => Fabricate(:item, :title => "mobile2"), :client_price => 3_000, :client_catalog => @user.client.client_catalog)
    mobile3 = Fabricate(:client_item, :item => Fabricate(:item, :title => "mobile3"), :client_price => 2_000, :client_catalog => @user.client.client_catalog)
    other = Fabricate(:client_item, :item => Fabricate(:item, :title => "other"), :client_price => 2_000, :client_catalog => @user.client.client_catalog)
    scheme.client_items = [mobile1, mobile2, mobile3, other]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
    
    Sunspot.index! ClientItem.all

    get :search_catalog, {:search => {:keyword => 'mobile', "point_range_min" => "30000", "point_range_max" => "40000"}, :scheme_slug => scheme.slug}

    response.should be_ok
    assigns[:total_count].should == 2
    assigns[:point_range].should include("min" => 20000, "max" => 40000, "selected_min" => 30000, "selected_max" => 40000)
  end

  it "should return warning if search keyword is not given" do
    request.env["HTTP_REFERER"] = root_url

    get :search_catalog, {:scheme_slug => scheme.slug}

    flash[:alert].should == "Please enter at least one search word"
    response.should redirect_to catalog_path_for(@user.user_schemes.first)
  end

  it "should render category facet" do
    category = Fabricate(:category, :title => "Electronics")
    sub_category = Fabricate(:category, :title => "Mobile", :ancestry => category.id)
    mobile = Fabricate(:client_item, :item => Fabricate(:item, :title => "mobile", :category => sub_category),
                       :client_catalog => @user.client.client_catalog)
    scheme.client_items = [mobile]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
    
    Sunspot.index! mobile

    get :search_catalog, {:search => {:keyword => 'mobile'}, :scheme_slug => scheme.slug}

    response.should be_ok
    assigns[:categories].size.should == 1
    assigns[:categories].first.value.should == "Mobile"
    assigns[:catalogs].user_scheme.should == user_scheme
  end

  it "should render parent category facet" do
    category = Fabricate(:category, :title => "Electronics")
    sub_category = Fabricate(:category, :title => "Mobile", :ancestry => category.id)
    mobile = Fabricate(:client_item, :item => Fabricate(:item, :title => "mobile", :category => sub_category),
                       :client_catalog => @user.client.client_catalog)
    scheme.client_items = [mobile]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
    
    Sunspot.index! mobile

    get :search_catalog, {:search => {:parent_category => 'Electronics'}, :scheme_slug => scheme.slug}

    response.should be_ok
    assigns[:parent_category].first.value.should == "Electronics"
  end

  it "should display message if no search results are found" do
    request.env["HTTP_REFERER"] = root_url

    get :search_catalog, {:search => {:keyword => 'mobile'}, :scheme_slug => scheme.slug}

    flash[:alert].should == "No Search Results with keyword \"mobile\" found"
    response.should render_template(:show)
  end

  it "should not include deleted items" do
    platinum_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'T shirt'), :client_catalog => @user.client.client_catalog, :deleted => true)
    scheme.client_items = [platinum_item]
    
    level_club_for(scheme, 'level1', 'platinum').catalog.add([platinum_item])

    get :search_catalog, {:search => {:keyword => 'shirt'}, :scheme_slug => scheme.slug}

    assigns[:results].should == []
    assigns[:total_count].should == nil
    flash[:alert].should == "No Search Results with keyword \"shirt\" found"
    response.should render_template(:show)
  end
end