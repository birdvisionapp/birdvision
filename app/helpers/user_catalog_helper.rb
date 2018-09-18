module UserCatalogHelper
  def catalog_path_for(user_scheme)
    if user_scheme.applicable_level_clubs.size == 1
      return catalog_path(:scheme_slug => user_scheme.scheme.slug, :id => user_scheme.applicable_level_clubs.first)
    end
    catalogs_path(:scheme_slug => user_scheme.scheme.slug)
  end

  def search_path_for(user_scheme)
    return nil unless user_scheme.present?
    search_catalog_path(:scheme_slug => user_scheme.scheme.slug)
  end

  def client_item_path_for(client_item, user_scheme)
    client_item_path(:scheme_slug => user_scheme.scheme.slug, :slug => client_item)
  end

  def new_order_path_for(user_scheme)
    new_order_path(:scheme_slug => user_scheme.scheme.slug)
  end

  def orders_path_for(user_scheme)
    orders_path(:scheme_slug => user_scheme.scheme.slug)
  end

  def order_preview_path_for(user_scheme)
    order_preview_path(:scheme_slug => user_scheme.scheme.slug)
  end

  def send_otp_path_for(user_scheme)
    send_otp_path(:scheme_slug => user_scheme.scheme.slug)
  end

  def my_account_link_helper user_scheme
    user_scheme.present? ? order_index_path(:scheme_slug => @user_scheme.scheme.slug) : order_index_path
  end

  def user_items(user_scheme, client_items)
    redeemable_client_item_ids = ClientItem.redeemable_ids(user_scheme)
    can_redeem = user_scheme.can_redeem?
    client_items.collect { |client_item|
      UserItem.new(user_scheme, client_item, can_redeem && redeemable_client_item_ids.include?(client_item.id))
    }
  end

  def otp_sending_option
    return nil unless current_user.client.allow_otp
    email = 'Email'
    mobile = 'Mobile number'
    if current_user.client.allow_otp_email && current_user.client.allow_otp_mobile
      "#{email}/#{mobile}"
    elsif current_user.client.allow_otp_email
      email
    elsif current_user.client.allow_otp_mobile
      mobile
    end
  end

  def current_user_client_name
    current_user.client.client_name if current_user.client
  end
end