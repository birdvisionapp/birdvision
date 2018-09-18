module Admin::NavigationHelper

  def build_nav_items
    report_tab = ['Reports', admin_download_reports_path, %w(download_reports)]

    case current_admin_user.role
    when AdminUser::Roles::RESELLER
      items = [
        {main_nav: ['Clients', admin_sales_reseller_dashboard_index_path, %w(dashboard participants orders)]},
        {main_nav: report_tab}
      ]
    when AdminUser::Roles::REGIONAL_MANAGER, AdminUser::Roles::REPRESENTATIVE
      client_id = RegionalManager.where(:admin_user_id => current_admin_user.id).first.client_id
      if (client_id == ENV['AL_CLIENT_ID'].to_i) && (current_admin_user.role == "regional_manager")
        rm_resource_items = [
          ['Uploads', admin_uploads_index_path, %w(uploads)],
          report_tab
        ] 
        items = [
          {main_nav: ['Dashboard', admin_regional_dashboard_path, %w(regional/dashboard)]},
          {main_nav: ['Participants', admin_users_path, %w(users)]},
          {main_nav: ['Orders',  admin_order_items_path,  %w(order_items)]},
          {main_nav: ['Resources'], sub_nav: rm_resource_items}
        ]
        items << {main_nav: ['Other Program'], sub_nav: [['SMS Based', admin_sms_based_dashboard_path, %w(reward_items unique_item_codes pack_sizes reward_item_points sms_based/dashboard)]]}
      else
        items = [
          {main_nav: ['Dashboard', admin_regional_dashboard_path, %w(regional/dashboard)]},
          {main_nav: ['Participants', admin_users_path, %w(users)]},
          {main_nav: report_tab}
        ]
      end
    else
      mm_items = [['Participants', admin_users_path, %w(users)], ['Schemes',  admin_schemes_path,  %w(schemes)]]
      mm_items << ['Clients',  admin_clients_path,  %w(clients)] if can?(:manage, Client)
      #as per requiremnt just hide it from menu options
      #mm_items << ['Points Statement',  admin_client_point_reports_path,  %w(client_point_reports)]
      redemption_items = [['Orders',  admin_order_items_path,  %w(order_items)]]
      redemption_items << ['Catalog',  admin_draft_items_path,  %w(master_catalog draft_items client_catalog client_item level_club_catalog scheme_catalog)] if can?(:manage, DraftItem)
      redemption_items = redemption_items + [['Suppliers',  admin_suppliers_path,  %w(suppliers)], ['Categories',  admin_categories_path,  %w(categories)]] if can?(:manage, Category)
      resource_items = [
        ['Uploads', admin_uploads_index_path, %w(uploads)],
        report_tab
      ]
      resource_items.unshift(['User Management', admin_user_management_dashboard_path, %w(resellers client_managers super_admins user_management/dashboard msps)]) if can?(:manage, ClientManager) || can?(:manage, RegionalManager)
      resource_items.push(['Payment Statement', admin_client_invoices_path, %w(client_invoices client_payments)]) if can?(:manage, ClientInvoice)
      resource_items.push(['Language Templates', admin_language_templates_path, %w(language_templates)]) if can?(:manage, LanguageTemplate)
      resource_items.push(['Telecom Circles', admin_telecom_circles_path, %w(telecom_circles)]) if can?(:manage, TelecomCircle)
      if client_manager_dashboard_check
        dashboard = ['Dashboard', admin_client_managers_widgets_path, %w(admin_client_managers_widgets)]
      else
        dashboard = ['Dashboard', admin_dashboard_path, %w(admin_dashboard)] 
      end
      items = [
        {main_nav: dashboard},
        {main_nav: ['Member Management'], sub_nav: mm_items},
        {main_nav: ['Redemption'], sub_nav: redemption_items},
        {main_nav: ['Resources'], sub_nav: resource_items}
      ]
      items << {main_nav: ['Other Program'], sub_nav: [['SMS Based', admin_sms_based_dashboard_path, %w(reward_items unique_item_codes pack_sizes reward_item_points sms_based/dashboard)]]} if can?(:view, :sms_dashboard)
      offer_items=[]
      if current_admin_user.role == AdminUser::Roles::SUPER_ADMIN
        offer_items = [
                        ['Template Listing', admin_templates_path, %w(targeted_offer)],
                        ['Targeted Offer Enabled Clients', admin_targeted_offers_path, %w(targeted_offer)],
                        ['Targeted Offer Listing', targeted_offer_list_admin_targeted_offer_managers_path, %w(targeted_offer)],
                        ['Targeted Offer Redemption', admin_to_transactions_path, %w(targeted_offer)]
                      ]
      elsif current_admin_user.role == AdminUser::Roles::CLIENT_MANAGER
        if to_enabled_client
          offer_items = [
                          ['Targeted Offer Listing', targeted_offer_list_admin_targeted_offer_managers_path, %w(targeted_offer)],
                          ['Targeted Offer Redemption', admin_to_transactions_path, %w(targeted_offer)]
                        ]
        end
      end
    end
    if to_enabled_client || (current_admin_user.role == AdminUser::Roles::SUPER_ADMIN and current_admin_user.msp_id.nil?) || check_msp_admin
      items << {main_nav: ['Targeted Offers'], sub_nav: offer_items}
    end
    items 
  end

  def active_admin_nav(url_parts)
    class_name = ''
    if is_current_one_of?(url_parts)
      class_name = 'active'
    end
    class_name
  end

  def client_manager_dashboard_check
    unless current_admin_user.role == AdminUser::Roles::SUPER_ADMIN
      ClientManager.where('admin_user_id = ?', current_admin_user.id).first.is_client_dashboard_unabled
    else
      false
    end
  end
  
  def check_msp_admin
    if is_msp_admin?
      if current_admin_user.msp.is_targeted_offer_enabled?
        return true
      end
    end
    false
  end
  
  def to_enabled_client
    if current_admin_user.role == AdminUser::Roles::CLIENT_MANAGER
      ClientManager.where(:admin_user_id => current_admin_user.id).first.client.is_targeted_offer_enabled
    else
      false
    end  
  end
  
  def is_super_admin?
    is_admin_user? && !current_admin_user.msp_id.present?
  end

  def is_msp_admin?
    is_admin_user? && current_admin_user.msp_id.present?
  end

  def is_admin_user?
    current_admin_user.super_admin?
  end
  
end
