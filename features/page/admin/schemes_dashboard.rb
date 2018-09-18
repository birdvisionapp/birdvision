module Page
  module Admin
    module SchemeDashboard

      def create_scheme_from scheme_info
        click_on 'New Scheme'
        select scheme_info['client'], :from => 'scheme_client_id'
        check 'scheme_single_redemption' if scheme_info['single_redemption']
        fill_in 'scheme_name', :with => scheme_info['name']
        fill_in 'scheme_total_budget_in_rupees', :with => scheme_info['total_budget_INR']
        fill_in 'scheme_start_date', :with => scheme_info['start_date']
        fill_in 'scheme_end_date', :with => scheme_info['end_date']
        fill_in 'scheme_redemption_start_date', :with => scheme_info['redemption_start_date']
        fill_in 'scheme_redemption_end_date', :with => scheme_info['redemption_end_date']
        attach_file("scheme_poster", Rails.root.to_s + scheme_info['image_path'])

        scheme_info['level_names'].split(",").each { |level|
          all("input[name='level_club_config[level_name][]']").last.set(level)
          find("a[rev='.level-container']").click
        }
        scheme_info['club_names'].split(",").each { |club|
          all("input[name='level_club_config[club_name][]']").last.set(club)
          find("a[rev='.club-container']").click
        }

        click_on 'Create Scheme'
      end

    end
  end
end
World(Page::Admin::SchemeDashboard)