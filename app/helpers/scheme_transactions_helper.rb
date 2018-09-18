module SchemeTransactionsHelper

  delegate :url_helpers, to: 'Rails.application.routes'

  def points_summary_for(transaction, is_admin = false, is_linked = true)
    {
      :description  => summary_description(transaction, is_admin, is_linked).html_safe,
      :credit       => bvc_currency(([SchemeTransaction::Action::CREDIT,SchemeTransaction::Action::REFUND].include?(transaction.action)) ? transaction.points : ''),
      :debit        => bvc_currency((transaction.action == SchemeTransaction::Action::DEBIT) ? transaction.points : ''),
      :balance      => bvc_currency(transaction.remaining_points)
    }
  end

  def points_summary_for_other_user(transaction, is_admin = false, is_linked = true)
    {
      :description  => summary_description_for_other_user(transaction, is_admin, is_linked).html_safe,
      :credit       => bvc_currency(([SchemeTransaction::Action::CREDIT,SchemeTransaction::Action::REFUND].include?(transaction.action)) ? transaction.points : ''),
      :debit        => bvc_currency((transaction.action == SchemeTransaction::Action::DEBIT) ? transaction.points : ''),
      :balance      => bvc_currency(transaction.remaining_points)
    }
  end

  def summary_description_for_other_user(transaction, is_admin, is_linked)
    case (transaction.action)
    when (transaction.transaction_type == 'UserScheme' && SchemeTransaction::Action::DEBIT), SchemeTransaction::Action::CREDIT
      scheme_path = (is_admin) ? url_helpers.admin_schemes_path : catalog_path_for(transaction.transaction)
      "Points are #{(transaction.action == SchemeTransaction::Action::DEBIT) ? 'debited' : 'loaded'} (#{transaction.scheme.name})" if transaction.scheme
    when (transaction.transaction_type == 'Order' && SchemeTransaction::Action::DEBIT), SchemeTransaction::Action::REFUND
      orders_path = (is_admin) ? url_helpers.admin_order_items_path : order_index_path
      action_tag = (transaction.action == SchemeTransaction::Action::REFUND) ? 'refunded' : 'redeemed'
      "Points are #{action_tag} (#{transaction.transaction.order_id})"
    end
  end

  def summary_description(transaction, is_admin, is_linked)
    case (transaction.action)
    when (transaction.transaction_type == 'UserScheme' && SchemeTransaction::Action::DEBIT), SchemeTransaction::Action::CREDIT
      scheme_path = (is_admin) ? url_helpers.admin_schemes_path : catalog_path_for(transaction.transaction)
      "Points are #{(transaction.action == SchemeTransaction::Action::DEBIT) ? 'debited' : 'loaded'} (#{link_to_if((is_linked && transaction.scheme.browsable?), transaction.scheme.name, scheme_path)})" if transaction.scheme
    when (transaction.transaction_type == 'Order' && SchemeTransaction::Action::DEBIT), SchemeTransaction::Action::REFUND
      orders_path = (is_admin) ? url_helpers.admin_order_items_path : order_index_path
      action_tag = (transaction.action == SchemeTransaction::Action::REFUND) ? 'refunded' : 'redeemed'
      "Points are #{action_tag} (#{link_to_if(is_linked, transaction.transaction.order_id, orders_path)})"
    end
  end

  def points_summary_info(type)
    total = current_user.total_points_for_past_and_active_schemes
    redeemed = current_user.total_redeemed_points
    case (type)
    when :total
      bvc_currency(total)
    when :redeemed
      bvc_currency(redeemed)
    when :remaining
      bvc_currency(total - redeemed)
    end
  end

end
