require "spec_helper"

describe ErrorsController do
  login_user
  context "routes" do
    it "should route requests correctly" do
      {:get => '/404'}.should route_to('errors#not_found')
      {:get => '/500'}.should route_to('errors#server_error')
    end
  end

  context "show error" do
    it "should show the errors page" do
      get :not_found
      assigns[:error].should == 404
      assigns[:message].should == "The Page you are looking for does not exist or is no longer available."
      assigns[:type].should == "Page Not Found"
      response.should render_template('errors/error_page')
      response.status.should == 404
    end

    it "should show the errors page" do
      get :server_error
      assigns[:error].should == 500
      assigns[:message].should == "We are sorry but there was an error. Please try again later."
      assigns[:type].should == "Something Went Wrong"
      response.should render_template('errors/error_page')
      response.should render_template('layouts/application')
      response.status.should == 500
    end

    context "layout" do
      login_admin

      it "should render admin layout for admin user" do
        get :not_found

        response.should render_template('layouts/admin')
      end
    end
  end
end