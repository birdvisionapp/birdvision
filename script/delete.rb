usernames = %w()
users_to_be_deleted = User.where("username IN (?)", usernames)
user_ids = users_to_be_deleted.collect(&:id)
user_schemes_to_be_deleted = UserScheme.where("user_id IN (?)", user_ids)
user_schemes_ids = user_schemes_to_be_deleted.collect(&:id)

OrderItem.includes(:order).where("orders.user_id IN (?)", user_ids).destroy_all
Order.where("user_id IN (?)", user_ids).destroy_all
Target.where("user_scheme_id IN (?)", user_schemes_ids).destroy_all
CartItem.includes(:cart).where("carts.user_scheme_id IN (?)", user_schemes_ids).destroy_all
Cart.where("user_scheme_id IN (?)",user_schemes_ids).destroy_all
user_schemes_to_be_deleted.destroy_all
users_to_be_deleted.destroy_all