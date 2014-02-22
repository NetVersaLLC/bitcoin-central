class CreateAccountOperationsPending < ActiveRecord::Migration
  def self.up
    create_table :account_operations_pending do |t|
      t.integer :account_id
      t.string :transaction_id
      t.string :payment_system
      t.decimal :amount, :precision => 16, :scale => 8
      t.string :currency, :null => false, :default => 'USD', :limit => 3
      
      t.timestamps
    end   
  end

  def self.down
  	drop_table :account_operations_pending
  end
end
