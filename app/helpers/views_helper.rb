module ViewsHelper

  def page_entries_info_message(results)
    if results.num_pages < 2
      results.size == 1 ? "Displaying 1 result" : "Displaying all #{results.size} results"
    else
      offset_value = results.per_page * (results.current_page - 1)
      "Displaying #{offset_value + 1} - #{offset_value + results.size } of #{results.total_count} results"
    end
  end

  def css_class_for_status status
    state_css_class_hash = {"sent_to_supplier" => "badge badge-warning",
                            "delivery_in_progress" => "badge badge-inverse",
                            "delivered" => "badge badge-success",
                            "incorrect" => "badge badge-info",
                            "refunded" => "badge badge-info",
                            "new" => "badge badge-important"}
    state_css_class_hash[status]
  end

  def class_of_status_action event
    ["incorrect", "refund"].include?(event) ? "btn" : "btn btn-success"
  end

  def date_range(start_date, end_date)
    return "-" if start_date.nil? && end_date.nil?
    return "Upto #{humanize_date(end_date)}" if start_date.nil?
    return "Effective from #{humanize_date(start_date)}" if end_date.nil?
    "#{humanize_date(start_date)} <b>to</b> #{humanize_date(end_date)}"
  end

  def ldate(date)
    l(date) if date.present?
  end

  def humanize_date(date)
    date.nil? ? "" : date.to_date.to_formatted_s(:long_ordinal)
  end

  def link_to_unless_one_of(url_parts, name, options, html_options={}, &block)
    link_to_unless is_current_one_of?(url_parts), name, options, html_options, &block
  end

  def active_link_to_if_one_of(url_parts, name, url, html_options={})
    active_classes = html_options.delete(:active_class)
    if is_current_one_of?(url_parts)
      active_classes.present? ? html_options.merge!({:class => active_classes}) : html_options.merge!({:class => 'active'})
    end
    link_to name, url, html_options
  end

  def is_current_one_of?(url_parts)
    url_parts.any? { |url_part| request.path.end_with?(url_part) || url_part == controller_name }
  end

  def catalog_urls(client)
    urls = [admin_client_catalog_path(client), edit_admin_client_catalog_path(client)] << client.schemes.collect { |s| [scheme_urls(s)] }
    urls.flatten
  end

  def scheme_urls(scheme)
    urls = [admin_scheme_catalog_path(scheme), edit_admin_scheme_catalog_path(scheme)] << level_club_urls(scheme)
    urls.flatten
  end

  def bvc_currency number
    if number.present?
      number = number_with_precision(number, :strip_insignificant_zeros => true)
      return "#{number.to_s.gsub(/(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?/, "\\1,")}"
    end
    return "-"
  end

  def schemes_for(client_item)
    client_item.schemes.collect(&:name).uniq.join(", \n") || '-'
  end

  def level_clubs_for(client_item, scheme)
    level_clubs = client_item.level_clubs.select {|lc| lc.scheme_id == scheme.id}
    level_clubs.collect(&:name).join(", \n") || "-"
  end

  def my_browsable_user_schemes_except user_scheme
    current_user.user_schemes.browsable.reject { |us| us == user_scheme }
  end

  def asset_host
    ActionController::Base.asset_host
  end


  def back_path
    @default_routes ||= {
        AdminUser::Roles::SUPER_ADMIN => admin_users_path,
        AdminUser::Roles::RESELLER => admin_sales_reseller_dashboard_index_path,
        AdminUser::Roles::CLIENT_MANAGER => admin_clients_path
    }
    current_admin_user.present? ? @default_routes[current_admin_user.role] : root_path
  end

  private
  def level_club_urls(scheme)
    scheme.level_clubs.collect { |lc| [admin_level_club_catalog_path(lc), edit_admin_level_club_catalog_path(lc)] }
  end

end

