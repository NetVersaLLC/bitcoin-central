class DataService

  CURRENCY = 'USD'



  def self.last_price
    (Operation.where('currency = ? and type = ?', CURRENCY, 'Trade').order('id desc').first().try(:ppc) || 0).to_f.round(4)
  end

  def self.day_low
    Rails.cache.fetch("data.day_low", {:expires_in => 1.minute}) do
      Operation.where('created_at > ? and currency = ? and type = ?',
                                 DateTime.now - 24.hours, CURRENCY, 'Trade').minimum("ppc").to_f.round(2) || 0
    end
  end

  def self.day_high
    Rails.cache.fetch("data.day_high", {:expires_in => 1.minute}) do
      Operation.where('created_at > ? and currency = ? and type = ?',
                      DateTime.now - 24.hours, CURRENCY, 'Trade').maximum("ppc").to_f.round(2) || 0
    end
  end

  def self.day_average
    Rails.cache.fetch("data.day_average", {:expires_in => 1.minute}) do
      Operation.where('created_at > ? and currency = ? and type = ?',
                      DateTime.now - 24.hours, CURRENCY, 'Trade').average("ppc").to_f.round(2) || 0
    end
  end

  def self.day_volume_btc
    Rails.cache.fetch("data.day_volume_btc", {:expires_in => 1.minute}) do
      Operation.where('created_at > ? and currency = ? and type = ?', DateTime.now - 24.hours, CURRENCY, 'Trade')
        .sum('traded_btc').to_f.round(2) || 0
    end
  end

  def self.day_volume_usd
    Rails.cache.fetch("data.day_volume_usd", {:expires_in => 1.minute}) do
      (self.day_volume_btc * self.day_average).round(2)
    end
  end
end