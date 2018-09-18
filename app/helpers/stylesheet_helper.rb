module StylesheetHelper

  def custom_theme_present?
    return false unless client_for_host
    client_for_host.present? ? client_for_host.custom_theme.present? : false
  end

  def custom_theme_url
    client_for_host.custom_theme.url
  end

  def client_logo_url
    client_for_host.logo.url(:medium) if client_for_host.present?
  end

end
