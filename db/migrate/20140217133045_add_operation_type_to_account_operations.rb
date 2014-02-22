class AddOperationTypeToAccountOperations < ActiveRecord::Migration
  def self.up
    add_column :account_operations, :operation_type, "enum('deposit', 'withdrawal', 'trade', 'fee')",
      :after => 'operation_id'
  end
  
  def self.down
    remove_column :account_operations, :operation_type
  end
end
