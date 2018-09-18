module NavigationHelpers

  def path_to(page_name)
    case page_name
      when /^sign in page$/
        new_user_session_path
      when /^admin sign in page$/
        new_admin_user_session_path
      when /homepage/
        items_index_path
      when /admin home/
        admin_root_path
      when /client catalog dashboard/

    end
  end
end
World(NavigationHelpers)