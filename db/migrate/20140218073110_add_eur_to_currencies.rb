class AddEurToCurrencies < ActiveRecord::Migration
  def self.up
    %w{eur}.each do |c|
      execute "INSERT INTO currencies (code, created_at, updated_at) VALUES ('#{c.to_s.upcase}', NOW(), NOW())"
    end 
  end

  def self.down
    Currency.delete_all(:code => 'EUR')
  end
end
