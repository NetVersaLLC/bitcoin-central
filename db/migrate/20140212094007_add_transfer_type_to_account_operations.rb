class AddTransferTypeToAccountOperations < ActiveRecord::Migration
  def self.up
    add_column :account_operations, :transfer_type, :string, :after => 'bank_account_id'
  end
  
  def self.down
    remove_column :account_operations, :transfer_type
  end
end
