
namespace :targeted_offer do
  desc "populate to_applicable table"
  task :to_task => :environment do
  	TargettedOffer.targeted_offer
  end
end


#rake targeted_offer:to_task