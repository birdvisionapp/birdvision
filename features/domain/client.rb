module Domain
  module CukeClient
    def create_client_from_given_data(table)
      table.hashes.each do |row|
        create_client_from row
      end
    end

  end
end

World(Domain::CukeClient)