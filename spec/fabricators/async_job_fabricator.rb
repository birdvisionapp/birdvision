Fabricator(:async_job) do
  status AsyncJob::Status::PROCESSING
end

Fabricator(:draft_item_async_job, :from => :async_job) do
  job_owner "DraftItem"
  csv Rack::Test::UploadedFile.new("spec/fixtures/draft_items.csv", "text/csv")
end

Fabricator(:user_async_job, :from => :async_job) do
  job_owner "User"
  csv Rack::Test::UploadedFile.new("spec/fixtures/upload_users_with_single_level_club.csv", "text/csv")
end
