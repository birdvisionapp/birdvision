module Csv

  class RepresentativeBuilder

    def initialize(representative, user)
      @representative = representative
      @user = user
    end

    def build
      @user.regional_managers_users.destroy_all if @user.id.present?
      representative = @user.regional_managers_users.build(regional_manager_id: @representative.id)
      representative
    end

  end

end
