require "spec_helper"

describe ClientItemsController do
  login_user

  let(:scheme) { Fabricate(:scheme, :levels => %w(level1 level2), :client => @user.client) }
  let(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }
  let(:client_item) { Fabricate(:client_item, :client_catalog => @user.client.client_catalog) }

  context "routes" do

    it "should route requests correctly" do
      {:get => '/schemes/random-scheme-slug/client_items/some-slug'}.should route_to('client_items#show', :slug => "some-slug", :scheme_slug => "random-scheme-slug")
    end
  end

  context "show" do

    it "should show an item" do
      update_level_club(user_scheme, "level1", "platinum")
      scheme.client_items = [client_item]
      level_club_for(scheme, 'level1', 'platinum').catalog.add([client_item])

      get :show, :slug => client_item.slug, :scheme_slug => scheme.slug

      assigns[:user_item].client_item.should == client_item
      response.should be_success
      response.should render_template(:show)
    end

    it "should not show items belonging to other levels" do
      update_level_club(user_scheme, "level1", "platinum")

      scheme.client_items = [client_item]
      level_club_for(scheme, 'level2', 'platinum').catalog.add([client_item])

      expect {
        get :show, :slug => client_item.slug, :scheme_slug => scheme.slug
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end