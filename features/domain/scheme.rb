module Domain
  module CukeScheme

    def create_scheme row
      visit(admin_schemes_path)
      create_scheme_from row
    end

    def view_scheme scheme_name
      navigate_to_scheme_catalog scheme_name
    end

    def logout_user
      click_logout
    end
  end
end

World(Domain::CukeScheme)