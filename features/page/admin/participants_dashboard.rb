module Page
  module Admin
    module ParticipantsDashboard
      def upload_participants_from_csv(csv_name, scheme, client)
        upload_csv_of_users(csv_name, scheme, client)
      end

      def activate_participant user_id
        table_row_id = find(:xpath, "//td[text()='#{user_id}']/..")[:id]
        within("##{table_row_id}") do
          find(".user_checkbox").set(true)
        end
        click_on 'Send Activation Link'
      end

      def inactive_participant user_id
        table_row_id = find(:xpath, "//td[text()='#{user_id}']/..")[:id]
        within("##{table_row_id}") do
          find(".user_checkbox").set(true)
        end
        click_on 'Inactive Participant(s)'
      end

      def active_participant user_id
        table_row_id = find(:xpath, "//td[text()='#{user_id}']/..")[:id]
        within("##{table_row_id}") do
          find(".user_checkbox").set(true)
        end
        click_on 'Active Participant(s)'
      end

      def open_upload_participants_page
        visit(admin_users_path)
        click_link("Upload Participants")
      end

      def attach_image_for_draft_item
        attach_file("draft_item_image", "#{Rails.root}/features/fixtures/s3.jpg")
      end

      def upload_csv_of_users(csv_name, scheme, client)
        attach_file("csv", "#{Rails.root}/features/fixtures/#{csv_name}")
        select "#{client} - #{scheme}", :from => "scheme"
        click_button "Start Upload"
        visit(admin_users_path)
      end

      def assert_for_schemes_of_client schemes
        schemes.each do |scheme|
          page.find("#scheme").has_content?(scheme).should be_true
        end
      end
    end
  end

end

World(Page::Admin::ParticipantsDashboard)