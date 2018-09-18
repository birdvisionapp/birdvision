class ClientPointReport < ActiveRecord::Base

  extend Admin::Reports::ClientPointStatement

  attr_accessible :balance, :client_id, :credit, :debit, :trans_date
  
  # Associations
  belongs_to :client

  # Validations
  validates :client, :trans_date, :presence => true

  # Callbacks
  before_save :build_credit_debit

  private

  def build_credit_debit
    client = self.client
    client_budget = ClientBudget.new([client.id], self.trans_date)
    if client_budget.present?
      self.credit = client_budget.total_points_credited
      self.debit = client_budget.total_points_redeemed
    end
    balance = build_client_balance(client)
    balance = balance + self.credit if client.client_point_reports.present?
    self.balance = (balance - self.debit)
    false if self.credit == 0 && self.debit == 0
  end

  def build_client_balance(client)
    (client.client_point_reports.last.present?) ? client.client_point_reports.last.balance : client.opening_balance
  end
  
end
