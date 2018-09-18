require 'capistrano/ext/multistage'
require "bundler/capistrano"

set :application, "birdvision"
set :repository, "git@github.com:bvcteam/birdvision.git"
set :stages, %w(production qa development)
set :default_stage, "development"

set :user, "www-data"
set :group, "www-data"

set :deploy_to, "/var/www/apps/#{application}"
set :scm, :git
set :use_sudo, false
set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true
# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
   desc "Populates the Database with seed data"
   task :seed do
     puts "\n\n=== Populating the #{stage} Database! ===\n\n"
     run "cd #{current_path}; rake db:seed RAILS_ENV=#{stage}"
   end
 end
