module BreadcrumbsHelper

  def can_show_back_link? search
    search.keyword.present? && search.category.present?
  end

  def can_show_home_link? search
    !can_show_back_link?(search)
  end

  def is_parent_category_active_in_breadcrumb search
    !can_show_back_link?(search) && search.parent_category.present? && !search.category.present?
  end

  def sub_category_breadcrumb search
    !can_show_back_link?(search) && search.category.present?
  end

end

