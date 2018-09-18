unless %w(qa staging production).include?(Rails.env)
  task :cleanup_and_start_solr do
    RAILS_ENV = ENV['RAILS_ENV'] = Rails.env = 'test'
    Rake::Task['sunspot_ext:solr:start'].invoke
  end

  %w(spec:controllers spec:helpers spec:lib spec:mailers spec:models spec:features spec:rcov).each do |spec_task_name|
    old_task = Rake::Task[spec_task_name]
    old_prerequisites = old_task.prerequisites.clone
    old_task.clear_prerequisites
    #odd way to enhance, but solr must be running first so that seed data gets
    #indexed during db:test:prepare which is in the old list of pre-requisites
    old_task.enhance [:cleanup_and_start_solr, *old_prerequisites]
  end
end