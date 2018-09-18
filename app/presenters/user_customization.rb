class UserCustomization
  
  def user_registration_update(code, user, parent)
    unique_item_code = UniqueItemCode.where(:code => code).first
    unique_item_code.update_attributes!(:user_id => user.id, :used_at => Time.now)
    link_code_after_registration(parent, unique_item_code.id) unless parent.nil?
    User.update_points_for(user, unique_item_code)
  end
  
  def user_scheme_update(this_user, scheme)
    attrs = {:user_id => this_user.id, :scheme_id => scheme.id}
            attrs.merge!(:level => scheme.level_clubs.first.level, :club => scheme.level_clubs.first.club)
            user_scheme = this_user.user_schemes.create!(attrs)
            user_scheme.save
  end

private

  def link_code_after_registration(parent, code_id)
    codes_slice =  "(#{code_id}, 'User', #{parent}, '#{Time.now}')"
    sql = "INSERT INTO `product_code_links` (`unique_item_code_id`, `linkable_type`, `linkable_id`, `created_at`) VALUES #{codes_slice}"
    ProductCodeLink.connection.execute sql
  end
end