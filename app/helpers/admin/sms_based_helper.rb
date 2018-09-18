module Admin::SmsBasedHelper

  def render_reward_item_points(pack_sizes)
    if pack_sizes.size > 0
      pack_sizes.map{|pack|
        pack_str = "#{pack.pack_size_metric} - #{pack.points} Points"
        pack_str
      }.join("<br />").html_safe
    end
  end

  def render_code_links(product_pack)
    params = {:q => {:reward_item_point_id_eq => product_pack.id}}
    product_codes = product_pack.unique_item_codes.select(:id).count
    link = ''
    unless current_admin_user.role == AdminUser::Roles::CLIENT_MANAGER
      link << content_tag(:span, link_to("Download", admin_sms_based_unique_item_codes_path(params), :class => 'label btn-primary')) if product_codes > 0
      link << content_tag(:span, link_to("Generate", new_admin_sms_based_unique_item_code_path(params), :class => 'label btn-primary')) if can? :create, UniqueItemCode
      link << content_tag(:span, link_to("Link", link_codes_admin_sms_based_reward_item_points_path(:q => {:unique_item_code_reward_item_point_id_eq => product_pack.id}), :class => 'label btn-warning')) if product_pack.single_tier? && product_codes > 0
    end
    content_tag(:div, link.html_safe, :class => 'pc-gen-dn-label')
  end

  def is_client_manager?
    current_admin_user.role == AdminUser::Roles::CLIENT_MANAGER
  end

end