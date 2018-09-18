
if Rails.env == 'development' || Rails.env == 'test'
  RSpec::Core::RakeTask.new(:pre_deploy_check) do |t|
    t.rspec_opts = "--tag pre_deploy_check"
  end

  task :tag_release do
    timestamp = Time.now.strftime("v-%Y%m%d_%H%M%S")
    `git tag #{timestamp}`
    `git push origin #{timestamp}`
  end
end
