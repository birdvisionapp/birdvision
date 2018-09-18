role :web, "192.168.35.2"
role :app, "192.168.35.2"
role :db,  "192.168.35.2", :primary => true
set :user, "birdv"
