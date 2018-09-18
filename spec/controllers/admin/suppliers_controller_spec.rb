require 'spec_helper'

describe Admin::SuppliersController do
  login_admin

  context "browse suppliers" do

    it "should show all suppliers " do
      supplier1 = Fabricate(:supplier, :name => "s1")
      supplier2 = Fabricate(:supplier, :name => "s2")

      get :index

      assigns[:suppliers].should == [supplier2, supplier1]
      response.should be_success
    end

  end
end