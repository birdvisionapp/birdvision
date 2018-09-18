module ButtonsHelper
  def continue_shopping_index_button user_scheme
    if user_scheme.nil?
      link_to 'Continue Shopping', schemes_path, :class => 'btn-continue-shopping'
    else
      return if user_scheme.single_redemption?
      link_to 'Add more to cart', catalog_path_for(user_scheme), :class => 'btn-continue-shopping'
    end
  end
end
