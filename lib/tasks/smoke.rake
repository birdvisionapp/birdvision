unless %w(qa staging production).include?(Rails.env)
  namespace :cucumber do
    task :local do
      sh("ENVIRONMENT='' bundle exec rake cucumber")
    end
    require 'cucumber/rake/task'

    Cucumber::Rake::Task.new({:smoke => 'db:test:prepare'}, 'Run cukes against an environment using ENVIRONMENT env variable') do |t|
      t.cucumber_opts = %w(--tags @smoke)
    end
  end
end