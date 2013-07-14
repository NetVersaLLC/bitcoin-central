class RemoveUnusedCurrencies < ActiveRecord::Migration
  def up
    Currency.delete_all()
    %w{btc usd}.each do |c|
      execute "INSERT INTO currencies (code, created_at, updated_at) VALUES ('#{c.to_s.upcase}', NOW(), NOW())"
    end
  end

  def down
    Currency.delete_all()
    %w{eur lrusd lreur pgau btc usd cad inr}.each do |c|
      execute "INSERT INTO currencies (code, created_at, updated_at) VALUES ('#{c.to_s.upcase}', NOW(), NOW())"
    end
  end
end
