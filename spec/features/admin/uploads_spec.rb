require 'request_spec_helper'

feature "Uploads Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  it "should list all uploads" do
    draft_item_job = Fabricate(:draft_item_async_job, :status => AsyncJob::Status::SUCCESS)
    user_job = Fabricate(:user_async_job, :status => AsyncJob::Status::FAILED)

    visit admin_uploads_index_path

    within("#accordion_heading_#{draft_item_job.id}") do
      page.should have_content("Draft Item - #{draft_item_job.csv_file_name}")
      page.should have_content("Success")
      page.should have_link "Delete", :href => admin_delete_upload_path(draft_item_job)
    end

    within("#accordion_heading_#{user_job.id}") do
      page.should have_content("Participant - #{user_job.csv_file_name}")
      page.should have_content("Failed")
      page.should have_link "Delete", :href => admin_delete_upload_path(user_job)
    end
  end
end
