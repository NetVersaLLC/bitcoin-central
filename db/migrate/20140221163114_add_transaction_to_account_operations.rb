class AddTransactionToAccountOperations < ActiveRecord::Migration
  def self.up
    add_column :account_operations, :transaction_id, :string, :after => 'amount'
  end

  def self.down
    remove_column :account_operations, :transaction_id
  end
end
