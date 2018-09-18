module Domain
  module CukeCategory
    def create_new_category category_info
      create_category category_info
    end
  end
end

World(Domain::CukeCategory)