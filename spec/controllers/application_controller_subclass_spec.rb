require "spec_helper"

class ApplicationControllerSubclass < ApplicationController
end

describe ApplicationControllerSubclass do
  controller(ApplicationControllerSubclass) do
    def index
      head :ok
    end
  end

  describe "handling caching" do
    it "should add no-caching headers to all requests" do
      get :index
      expected_headers = {"Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
                          "Pragma" => "no-cache"}

      response.headers.should include expected_headers
      response.headers["Expires"].to_date.should == 1.year.ago.to_date
    end
  end
end