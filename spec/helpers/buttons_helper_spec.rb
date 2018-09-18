require 'spec_helper'

describe ButtonsHelper do

  it "should render continue shopping to index button" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3))
    user = user_scheme.user
    helper.stub(:current_user).and_return(user)
    scheme_slug = user.user_schemes.first.scheme.slug
    helper.continue_shopping_index_button(user_scheme).should have_selector("a[href='/schemes/#{scheme_slug}/catalogs']")
  end
  it "should render continue shopping linked to scheme index button if user has not selected any scheme" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme))
    user = user_scheme.user
    helper.stub(:current_user).and_return(user)
    helper.continue_shopping_index_button(nil).should have_selector("a[href='/schemes']")
  end

  it "should not render continue shopping for single redemption users" do
    user_scheme = Fabricate(:single_redemption_user_scheme, :scheme => Fabricate(:scheme, :single_redemption => true))
    user = user_scheme.user
    helper.stub(:current_user).and_return(user)
    helper.continue_shopping_index_button(user_scheme).should be_nil
  end

end

