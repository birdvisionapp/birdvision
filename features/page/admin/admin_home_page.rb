module Page
  module Admin
    module AdminHomePage
      def navigate_to_admin_home
        visit path_to("admin home")
      end
    end
  end
end

World(Page::Admin::AdminHomePage)