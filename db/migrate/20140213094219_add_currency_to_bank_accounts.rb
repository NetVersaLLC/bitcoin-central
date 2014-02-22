class AddCurrencyToBankAccounts < ActiveRecord::Migration
  def self.up
    add_column :bank_accounts, :currency, :string,
      :default => 'USD',
      :null => false,
      :after => 'iban'
      
    add_column :bank_accounts, :bank_type, :string,
      :default => 'US',
      :null => false,
      :after => 'iban'
  end
  
  def self.down
    remove_column :bank_accounts, :currency
    remove_column :bank_accounts, :bank_type
  end
end
