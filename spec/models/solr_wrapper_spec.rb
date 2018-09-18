require 'spec_helper'

describe SolrWrapper do
  let(:electronics_category) { Fabricate(:category, :title => "Electronics") }
  let(:misc_category) { Fabricate(:category, :title => "Misc") }
  let(:user_scheme) { Fabricate(:user_scheme, :scheme => Fabricate(:scheme)) }
  let(:user) { user_scheme.user }
  let(:scheme) { user_scheme.scheme }

  before(:each) do
    Sunspot.remove_all!
  end

  context "search in fields" do

    it "should search in title" do
      fridge = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "LG Fridge", :category => misc_category))
      guitar = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "F shape guitar", :category => misc_category))
      scheme.client_items = [fridge, guitar]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)

      Sunspot.index! ClientItem.all

      search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "guitar"), user, user.user_schemes.first)
      results = search_criteria.results

      results.should == [guitar]
    end

    it "should search in non deleted items" do
      fridge = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "LG Fridge", :category => misc_category))
      guitar = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "F shape guitar", :category => misc_category), :deleted => true)
      scheme.client_items = [fridge, guitar]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all

      search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "guitar"), user, user.user_schemes.first)
      results = search_criteria.results

      results.should_not include guitar
    end

    it "should return items in search results if non deleted items found" do
      guitar = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "F shape guitar", :category => misc_category), :deleted => false)
      scheme.client_items = [guitar]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all

      search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "guitar"), user, user.user_schemes.first)
      results = search_criteria.results

      results.should == [guitar]
    end

    it "should search in description" do
      guitar = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "Mast Guitar", :description => "F shape guitar", :category => misc_category))
      fridge = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "Bore Fridge", :description => "Samsung Fridge with awesome cooling facility", :category => misc_category))
      scheme.client_items = [fridge, guitar]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all

      search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "awesome"), user, user.user_schemes.first)
      results = search_criteria.results

      results.should == [fridge]
    end

    it "should search in category" do
      television = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => 'television', :category => electronics_category))
      scheme.client_items = [television]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all

      results = SolrWrapper.search_catalog(Search.new(:keyword => "television"), user, user.user_schemes.first).results
      results.should == [television]
    end

    it "should search in parent category" do
      category = Fabricate(:category, :title => "Electronics")
      mobile = Fabricate(:category, :title => "Mobile", :parent => category)
      television = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => 'television', :category => mobile))
      scheme.client_items = [television]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all

      results = SolrWrapper.search_catalog(Search.new(:parent_category => "Electronics"), user, user.user_schemes.first).results
      results.should == [television]
    end

    #todo -- check this for failure
    it "should facet results by category" do
      television = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => 'television', :category => electronics_category, :category => electronics_category))
      scheme.client_items = [television]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all

      category_facets = SolrWrapper.search_catalog(Search.new(:keyword => "television"), user, user.user_schemes.first).facet_by(:category)
      category_facets.size.should == 1
      category_facets.first.value.should == 'Electronics'

    end

    it "should return results applicable for given user's scheme" do
      client_item1 = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => 'television', :category => electronics_category, :category => electronics_category))
      scheme = user.user_schemes.first.scheme
      scheme.client_items = [client_item1]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)

      client_item2 = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => 'radio', :category => electronics_category, :category => electronics_category))
      scheme2 = Fabricate(:scheme, :name => "new scheme", :client => user.client)
      Fabricate(:user_scheme, :user => user, :scheme => scheme2)
      scheme2.client_items = [client_item2]
      level_club_for(scheme2, 'level1', 'platinum').catalog.add(scheme.client_items)
      scheme2.save!


      Sunspot.index! ClientItem.all

      category_facets = SolrWrapper.search_catalog(Search.new(:keyword => "television"), user, user.user_schemes.first).facet_by(:category)
      category_facets.size.should == 1
      category_facets.first.value.should == 'Electronics'

    end

  end

  context "filter" do
    before do
      @guitar = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :client_price => 5_000, :item => Fabricate(:item, :title => 'electric guitar', :description => 'electronics: electric guitar', :category => misc_category))
      @tv = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :client_price => 25_000, :item => Fabricate(:item, :title => 'tv', :description => 'electronics: tv', :category => electronics_category))
      @fridge = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :client_price => 15_000, :item => Fabricate(:item, :title => 'fridge', :description => 'electronics: fridge', :category => electronics_category))
      @car = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :client_price => 5_00_000, :item => Fabricate(:item, :title => 'car', :description => 'car', :category => misc_category))
      scheme.client_items = [@guitar, @tv, @fridge, @car]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all
    end

    it "should filter search results by point range" do

      search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "electronics", :point_range_min => 1_20_000, :point_range_max => 2_50_000), user, user.user_schemes.first)

      search_criteria.results.should =~ [@tv, @fridge]
    end

    it "should not filter results if point range is not provided" do

      search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "electronics", :point_range_min => 12_000), user, user.user_schemes.first)

      search_criteria.results.should =~ [@tv, @fridge, @guitar]
    end

    it "should filter search results by category" do
      search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "electronics", :category => misc_category.title), user, user.user_schemes.first)

      search_criteria.results.should == [@guitar]
    end
  end

  context "relevance" do
    it "should give precedence to title" do
      mac = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:macbook_pro, :title => "mac book Pro 13 inch", :category => electronics_category))
      imac = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:macbook_pro, :title => "IMAC", :description => "20 inch", :category => electronics_category))
      iphone = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:macbook_pro, :title => "5 inch by 3 inch wide iphone", :description => "20 inch", :category => electronics_category))

      scheme.client_items = [mac, imac, iphone]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)

      Sunspot.index! ClientItem.all
      search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "inch"), user, user.user_schemes.first)
      results = search_criteria.results

      results.first.should == iphone
      results[1].should == mac
      results.last.should == imac

    end
  end

  it " should paginate results" do
    galaxy_black = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "galaxy black", :category => electronics_category))
    galaxy_plus = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "galaxy plus", :description => "galaxy plus black", :category => electronics_category))
    nokia_black = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "nokia black", :description => "nokia black", :category => electronics_category))
    scheme.client_items = [galaxy_black, galaxy_plus, nokia_black]
    level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)

    Sunspot.index! ClientItem.all

    search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "black", :page => 1, :per_page => 2), user, user.user_schemes.first)
    results = search_criteria.results

    search_criteria.total.should == 3
    results.count.should == 2

    search_criteria = SolrWrapper.search_catalog(Search.new(:keyword => "black", :page => 2, :per_page => 1), user, user.user_schemes.first)
    results = search_criteria.results
    results.count.should ==1
  end

  context "stats" do
    it "should return solr stats" do
      galaxy_black = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "galaxy black", :category => electronics_category), :client_price => 10_000)
      galaxy_plus = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :client_price => 20_000, :item => Fabricate(:item, :title => "galaxy plus", :description => "galaxy plus black", :category => electronics_category))
      nokia_black = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :client_price => 30_000, :item => Fabricate(:item, :title => "nokia black", :description => "nokia black", :category => electronics_category))
      scheme.client_items = [galaxy_black, galaxy_plus, nokia_black]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)

      Sunspot.index! ClientItem.all

      stats = SolrWrapper.search_catalog(Search.new(:keyword => "black", :stats => :points), user, user.user_schemes.first).stats_by(:points)

      stats.should include("min" => 1_00_000, "max" => 3_00_000, "count" => 3)
    end

    it "should return solr stats without including price filter" do
      galaxy_black = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :item => Fabricate(:item, :title => "galaxy black", :category => electronics_category), :client_price => 10_000)
      galaxy_plus = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :client_price => 20_000, :item => Fabricate(:item, :title => "galaxy plus", :description => "galaxy plus black", :category => electronics_category))
      nokia_black = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :client_price => 30_000, :item => Fabricate(:item, :title => "nokia black", :description => "nokia black", :category => electronics_category))
      scheme.client_items = [galaxy_black, galaxy_plus, nokia_black]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)

      Sunspot.index! ClientItem.all

      stats = SolrWrapper.search_catalog(Search.new(:keyword => "black", :point_range_min => "200000", :point_range_max => "300000", :stats => :points), user, user.user_schemes.first).stats_by(:points)
      stats.should include("min" => 1_00_000, "max" => 3_00_000, "count" => 3)
    end

  end

  context "single redemption" do
    it "should return results applicable for given user's level" do
      user_scheme = Fabricate(:single_redemption_user_scheme, :scheme => Fabricate(:scheme_3x3))
      update_level_club(user_scheme, 'level1', nil)
      user = user_scheme.user
      client = user.client

      client_item1 = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Item1 Canon 1D'), :client_catalog => client.client_catalog)
      client_item2 = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Item2 Canon 1D'), :client_catalog => client.client_catalog)
      scheme = user_scheme.scheme
      scheme.client_items = [client_item1, client_item2]
      level_club_for(scheme, 'level1', 'gold').catalog.add([client_item1])
      level_club_for(scheme, 'level2', 'gold').catalog.add([client_item2])
      Sunspot.index! ClientItem.all

      search_response = SolrWrapper.search_catalog(Search.new(:keyword => "canon", :page => 1, :per_page => 2), user, user_scheme)

      search_response.total.should == 1
      search_response.results.first.should == client_item1

    end
  end
end