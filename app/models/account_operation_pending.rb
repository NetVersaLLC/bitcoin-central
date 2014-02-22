require 'digest'

class AccountOperationPending < ActiveRecord::Base
  belongs_to :account
  set_table_name "account_operations_pending"
  validates_inclusion_of :payment_system, :in => ['dwolla', 'okpay']
end
