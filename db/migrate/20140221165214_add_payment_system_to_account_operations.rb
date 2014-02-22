class AddPaymentSystemToAccountOperations < ActiveRecord::Migration
  def self.up
    add_column :account_operations, :payment_system, :string, :after => 'transaction_id'
  end

  def self.down
    remove_column :account_operations, :payment_system
  end
end
