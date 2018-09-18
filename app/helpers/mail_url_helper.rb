module MailUrlHelper
  def edit_password_path_for user
    #edit_user_password_url(add_client_host(user, :reset_password_token => user.reset_password_token, :mode => "activate"))
    params = {:reset_password_token => user.reset_password_token, :mode => "activate"}
    password_reset_url = (user.client.custom_reset_password_url? && user.client.client_url.present?) ? "#{user.client.client_url.gsub(/\/+$/, '')}/user_password_reset?#{params.to_query}" : edit_user_password_url(add_client_host(user, params))
    password_reset_url
  end

  def root_url_for user
    url = (user.client.custom_reset_password_url? && user.client.client_url.present?) ? user.client.client_url : root_url(add_client_host(user))
    url
  end

  def order_url_for user, order_item
    order_url(add_client_host(user, :id => order_item.order, :scheme_slug => order_item.scheme.slug))
  end

  def orders_link_for user
    order_index_url(add_client_host(user))
  end

  def contact_us_url_for user
    contact_us_url(add_client_host(user, :ccode => user.client.code))
  end

  def add_client_host(user, params={})
    user.client.domain_name.present? ? params.merge(:host => user.client.domain_name) : params
  end
end
