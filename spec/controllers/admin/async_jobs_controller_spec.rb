require 'spec_helper'

describe Admin::AsyncJobsController do

  context "routes" do
    it "should route correctly" do
      {:get => admin_uploads_index_path}.should route_to("admin/async_jobs#index")
      {:delete => admin_delete_upload_path(1)}.should route_to("admin/async_jobs#destroy", :id => "1")
    end
  end

  login_admin
  it "should list all the upload jobs" do
    async_job = Fabricate(:draft_item_async_job)

    get :index

    assigns[:async_jobs].should == [async_job]
  end

  it "should delete the delayed job " do
    async_job = Fabricate(:draft_item_async_job)

    delete :destroy, :id => async_job.id

    AsyncJob.count.should == 0
    response.should redirect_to(admin_uploads_index_path)
  end
end