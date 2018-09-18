class Ability
  include CanCan::Ability

  def initialize(admin_user)
    case admin_user.role
    when AdminUser::Roles::SUPER_ADMIN
      can :manage, :all
      unless admin_user.manage_roles
        cannot :manage, :admin_management
        cannot [:create, :update, :destroy], AdminUser, role: AdminUser::Roles::SUPER_ADMIN, msp_id: nil
      end
      cannot :view, :reseller_dashboard
      cannot :approve_order, OrderItem
      if admin_user.msp_id.present?
        cannot :manage, :all
        can :view, :sms_dashboard
        can :manage, [AlTransactionIssue, AlTransaction]
        msp_id = admin_user.msp_id
        can :read, Msp, :id => msp_id
        client_ids = Client.where(msp_id: msp_id).pluck(:id)
        scheme_ids = Scheme.where(client_id: client_ids).pluck(:id)
        can :manage, [Client, Category, Supplier], msp_id: msp_id
        #can :create, [Category, Supplier]
        can :create, [UniqueItemCode, CatalogItem, ClientItem, Item, AdminUser, ClientPointCredit, ClientPointReport, AccessGrant, Scheme, UserRole, User, ClientManager, SchemeTransaction, ClientPointReport, RewardItem, RewardItemPoint, ClientAdmin, RegionalManager, Representative, ItemSupplier]
        can :manage, [DraftItem, ItemSupplier], supplier: {msp_id: msp_id}
        can :manage, Item, category: {msp_id: msp_id}
        can :manage, [ClientPointCredit, ClientPointReport, AccessGrant, Scheme, UserRole, User, ClientManager, SchemeTransaction, ClientPointReport, RewardItem, ClientAdmin, RegionalManager, Representative], client_id: client_ids
        can :manage, [Level, Club]
        can :manage, AdminUser, msp_id: msp_id
        can :manage, [UserScheme, LevelClub], scheme_id: scheme_ids
        can :manage, Target, user_scheme: {scheme_id: scheme_ids}
        can :manage, Order, user: {client_id: client_ids}
        can :manage, OrderItem, scheme_id: scheme_ids
        #can :manage, ClientPayment, client_invoice: {client_id: client_ids}
        can :read, [LanguageTemplate, TelecomCircle]
        can :manage, RegionalManagersTelecomCircle, regional_manager: {client_id: client_ids}
        can :manage, [DownloadReport, AsyncJob], admin_user: {msp_id: msp_id}
        can :manage, :admin_management
	      reward_item_ids = RewardItem.where(client_id: client_ids).pluck(:id)
        can :manage, RewardItem, client_id: client_ids
        can :manage, RewardItemPoint, reward_item_id: reward_item_ids
        can :manage, UniqueItemCode, reward_item_point: {reward_item_id: reward_item_ids}
        can :manage, ProductCodeLink, linkable_type: 'User', linkable_id: User.where(client_id: client_ids).pluck(:id)
        can :manage, PackTierConfig, user_role: {client_id: client_ids}
        can :manage, CatalogItem, client_item: {client_id: client_ids}
        can :manage, ClientItem, item: {category: {msp_id: msp_id}}
        can :manage, RegionalManagersUser, regional_manager: {client_id: client_ids}
        can :manage, ClientCatalog, client: {id: client_ids}
        can :manage, RewardProductCatagory, client: {id: client_ids}
        can :manage, ToTransaction
        #can :manage, [ProductCodeLink, PackTierConfig]
        cannot :view, :reseller_info
        cannot :approve_order, OrderItem
        unless admin_user.manage_roles
          cannot :manage, :admin_management
          cannot [:create, :update, :destroy], AdminUser, role: AdminUser::Roles::SUPER_ADMIN
        end
      end
    when AdminUser::Roles::RESELLER
      can :view, :reseller_dashboard
      cannot :view, :admin_dashboard
      cannot :approve_order, OrderItem
      can :manage, DownloadReport, :admin_user_id => admin_user.id
    when AdminUser::Roles::CLIENT_MANAGER
      client = ClientManager.associated_client_for(admin_user)
      client_id = client.id
      can :view, :admin_dashboard
      can :read, Client, :id => client_id
      can :read, Scheme, :client_id => client_id
      can :read, UserRole, :client_id => client_id
      can :manage, User, :client_id => client_id
      cannot :destroy, User, :client_id => client_id
      can :read, UserScheme, :scheme => {:client_id => client_id}
      can :read, OrderItem, :scheme => {:client_id => client_id}
      can :approve_order, OrderItem, :scheme => {:client_id => client_id}
      #can :read, ClientCatalog, :client => {:id => client_id} By Balaji: - Disabled Catalog view for Client Manager for now.
      #can :read, CatalogItem, :client_item => {:client => {:id => client_id}}
      can :read, LevelClub, :scheme => {:client_id => client_id}
      can :read, [SchemeTransaction, ClientPointReport], :client_id => client_id
      cannot :view, :bvc_monetary_fields
      cannot :view, :activation_link
      cannot :view, :reseller_info
      if client.sms_based?
        can :view, :sms_dashboard
        can :read, RewardItem, :client_id => client_id
        reward_item_ids = RewardItem.where(:client_id => client_id).pluck(:id)
        can :read, RewardProductCatagory, :client_id => client_id
        can :read, RewardItemPoint, :reward_item_id => reward_item_ids
        can :read, UniqueItemCode, :reward_item_point => {:reward_item_id => reward_item_ids}
        can :read, [ProductCodeLink, PackTierConfig]
      end
      can :manage, [DownloadReport, AsyncJob], :admin_user_id => admin_user.id
      can [:create, :read], ClientInvoice, :client_id => client_id
      can [:create, :read], ClientPayment unless client.msp_id.present?
      can :read, LanguageTemplate
      rm = ClientAdmin.where(:client_id => client_id).select([:id, :admin_user_id])
      can :manage, [ClientAdmin, RegionalManager, Representative], :client_id => client_id
      can :manage, AdminUser, :id => rm.map(&:admin_user_id)
      can :read, TelecomCircle
      can :manage, RegionalManagersTelecomCircle, :regional_manager_id => rm.map(&:id)
      can :read, ToTransaction
    when AdminUser::Roles::REGIONAL_MANAGER
      client = RegionalManager.associated_client_for(admin_user)
      client_id = client.id
      can :view, :regional_dashboard
      if client_id == ENV['AL_CLIENT_ID'].to_i
        regional_manager = admin_user.regional_manager.region.upcase
        user_ids = AlChannelLinkage.where(:ro_code => regional_manager).collect(&:user_id).compact.uniq
        can :view, :admin_dashboard
        can :read, Client, :id => client_id
        can :manage, User, :id => user_ids
        can :read, Scheme, :client_id => client_id
        can :read, UserRole, :client_id => client_id
        can :read, UserScheme, :scheme => {:client_id => client_id}
        can :read, OrderItem, :scheme => {:client_id => client_id}
        can :approve_order, OrderItem, :scheme => {:client_id => client_id}
        #can :read, ClientCatalog, :client => {:id => client_id} By Balaji: - Disabled Catalog view for Client Manager for now.
        #can :read, CatalogItem, :client_item => {:client => {:id => client_id}}
        can :read, LevelClub, :scheme => {:client_id => client_id}
        can :read, [SchemeTransaction, ClientPointReport], :client_id => client_id
        cannot :view, :bvc_monetary_fields
        cannot :view, :activation_link
        cannot :view, :reseller_info
        if client.sms_based?
          can :view, :sms_dashboard
          can :read, RewardItem, :client_id => client_id
          reward_item_ids = RewardItem.where(:client_id => client_id).pluck(:id)
          can :read, RewardProductCatagory, :client_id => client_id
          can :read, RewardItemPoint, :reward_item_id => reward_item_ids
          can :read, UniqueItemCode, :reward_item_point => {:reward_item_id => reward_item_ids}
          can :read, [ProductCodeLink, PackTierConfig]
        end
        can :manage, [DownloadReport, AsyncJob], :admin_user_id => admin_user.id
        can [:create, :read], ClientInvoice, :client_id => client_id
        can [:create, :read], ClientPayment unless client.msp_id.present?
        can :read, LanguageTemplate
        rm = ClientAdmin.where(:client_id => client_id).select([:id, :admin_user_id])
        can :manage, [ClientAdmin, RegionalManager, Representative], :client_id => client_id
        can :manage, AdminUser, :id => rm.map(&:admin_user_id)
        can :read, TelecomCircle
        can :manage, RegionalManagersTelecomCircle, :regional_manager_id => rm.map(&:id)
        can :read, ToTransaction
      else
        can :manage, User, :client_id => client.id, :telecom_circle_id => admin_user.regional_manager.telecom_circles.map(&:id)
        can :read, [SchemeTransaction, Scheme, UserRole], :client_id => client.id
        cannot :view, :admin_dashboard
        cannot :approve_order, OrderItem
        can :manage, DownloadReport, :admin_user_id => admin_user.id
      end
    when AdminUser::Roles::REPRESENTATIVE
      client = Representative.associated_client_for(admin_user)
      can :read, [SchemeTransaction, Scheme, UserRole], :client_id => client.id
      linkable_ids = admin_user.representative.users.pluck(:id)
      user_ids = UniqueItemCode.joins(:product_code_link).used.where('product_code_links.linkable_type = ? AND product_code_links.linkable_id IN(?)', 'User', linkable_ids).pluck('DISTINCT(unique_item_codes.user_id)')
      can :manage, User, :client_id => client.id, :id => user_ids
      can :view, :regional_dashboard
      cannot :view, :admin_dashboard
      can :manage, DownloadReport, :admin_user_id => admin_user.id
      cannot :approve_order, OrderItem
    else
      cannot :manage, :all
    end
  end
end
