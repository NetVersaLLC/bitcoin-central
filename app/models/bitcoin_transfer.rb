class BitcoinTransfer < Transfer
  attr_accessible :address

  validates :address,
    :bitcoin_address => true,
    :not_mine => true,
    :presence => true

  validates :currency,
    :inclusion => { :in => ["BTC"] }

  def address=(a)
    self[:address] = a.strip
  end

  def execute
    # TODO : Re-implement instant internal transfer
    #if bt_tx_id.blank? && pending? && (Bitcoin::Client.instance.get_balance >= amount.abs)
    #  update_attribute(:bt_tx_id, Bitcoin::Client.instance.send_to_address(address, amount.abs))
    #  process!
    #end
  end

  def make_withdraw
    btc_amount = self.amount.abs
    begin
      if self.state != 'processed' && Bitcoin::Client.instance.get_balance >= btc_amount && !self.address.blank?
        self.bt_tx_id = Bitcoin::Client.instance.send_to_address(self.address, btc_amount)
        self.state = 'processed'
        self.save!
      else
        return false
      end
    rescue
      return false
    else
      return true
    end
  end

end

