namespace :orders do
  desc "Match ordes in the DB"
  task :match_pending_orders => :environment do
    Lockfile.lock(:match_pending_orders) do
      TradeOrder.match_pending_orders!
    end
  end
  
  task :close_invalid_orders => :environment do
    Lockfile.lock(:close_invalid_orders) do
      TradeOrder.close_invalid_orders!
    end
  end
  
  #task :fill_test_orders => :environment do
  #  trade_order = TradeOrder.find(137)
  #  trade_order2 = TradeOrder.find(139)
    
  #  user = User.find(trade_order.user_id)
  #  user2 = User.find(trade_order2.user_id)
    
  #  90.times do
  #    trade_order_tmp = trade_order.dup
  #    trade_order_tmp.user = user
  #    trade_order_tmp.save!
      
  #    trade_order_tmp = trade_order2.dup
  #    trade_order_tmp.user = user2
  #    trade_order_tmp.save!
  #  end
  #end
  
  #task :performance_test  => :environment do
  #  t1 = Time.now
    
  #  100.times do
      #Lockfile.lock(:match_pending_orders) do
  #      TradeOrder.match_pending_orders!
      #end
  #  end
    
  #  t2 = Time.now
  #  delta = t2 - t1
    
  #  puts("Performance test took: #{delta} ms")
  #end
end