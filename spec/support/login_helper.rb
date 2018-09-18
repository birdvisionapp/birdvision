module LoginHelper
  def login_admin
    before(:each) do
      @admin = Fabricate(:admin_user)
      sign_in :admin_user, @admin
    end
  end

  def login_reseller
    before(:each) do
      @admin = Fabricate(:reseller_admin_user)
      sign_in :admin_user, @admin
    end
  end

  def login_user
    before(:each) do
      @user = Fabricate(:user)
      sign_in @user
    end
  end
end