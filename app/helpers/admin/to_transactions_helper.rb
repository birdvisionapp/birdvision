module Admin::ToTransactionsHelper
  
  def msp_info(transaction)
    unless transaction.nil?
      transaction.targeted_offer_config.msp.name unless transaction.targeted_offer_config.msp_id.nil?    
    end
  end
  
  def client_info(transaction)
    unless transaction.nil?
      transaction.targeted_offer_config.client.client_name unless transaction.targeted_offer_config.client_id.nil? 
    end
  end
  
  def user_info(transaction)
    unless transaction.nil?
      transaction.user
    end
  end
  
  def to_type(transaction)
    transaction.targeted_offer_config.template.targeted_offer_type.offer_type_name
  end
  
  def incentive_type_info(transaction)
    type = transaction.incentive.incentive_type
    if type == "percentage"
      return "Auto Fullfillment", "#{transaction.incentive.incentive_detail}% extra points"
    else
      return "Manual", "Gift - #{transaction.incentive.incentive_detail}"
    end
  end
  
  def transaction_status(transaction)
    type = transaction.incentive.incentive_type
    if type == "percentage"
      "Deliverd"
    else
      ""
    end
  end
  
  def transaction_result(transaction)
    type = transaction.incentive.incentive_type
    if type == "percentage" and transaction.status == "delivered"
      "Deliverd"
    else
      "Pending"
    end
  end
end
