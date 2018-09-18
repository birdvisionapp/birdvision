class SchemeTransaction < ActiveRecord::Base

  extend Admin::Reports::PointsSummaryReport
  
  attr_accessible :client_id, :points, :action, :scheme_id, :transaction_type, :transaction_id, :user_id, :remaining_points, :created_at, :updated_at

  # Associations
  belongs_to :client
  belongs_to :user
  belongs_to :scheme
  belongs_to :transaction, :polymorphic => true

  module Action
    CREDIT  = 'credit'
    DEBIT   = 'debit'
    REFUND  = 'refund'
  end

  # Scopes
  [:credit, :debit, :refund].each do |action|
    scope action, where(action: action)
  end

  def self.record(scheme_id, action, transaction, points)
    return nil unless points > 0
    user = transaction.user
    puts "****************self.record***************************"
    puts "scheme_id-----#{scheme_id}"
    puts "action-----#{action}"
    puts "transaction-----#{transaction.inspect}"
    puts "points-----#{points}"
    puts "user-----#{user.inspect}"
    SchemeTransaction.create!(
      client_id: user.client_id, user_id: user.id, scheme_id: scheme_id,
      transaction_type: transaction.class.to_s, transaction_id: transaction.id,
      action: action, points: points, remaining_points: user.total_redeemable_points)
  end

end
