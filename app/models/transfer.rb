class Transfer < AccountOperation
  self.inheritance_column = nil
  include ActiveRecord::Transitions

  FEES_PERCENT = {
          'paypal' => 1,
          'okpay' => 4.0,
          'wire_us' => 1.5,
          'wire_international' => 1.5

  }
  
  FEES = {
          'wire_us' => 25.0,
          'wire_international' => 150.0,
          'dwolla' => 1.0,
          'btc' => 0.001,
          'ltc' => 0.1
  }

  attr_accessor :bank_type
  attr_accessible :transfer_type

  # before_validation :round_amount,
  #  :on => :create  
  
  after_create :execute

  validates :amount,
    :numericality => true,
    #:user_balance => true,
    :minimal_amount => true,
    :maximal_amount => true

  validates :currency,
    :inclusion => { :in => ["USD", "EUR", "LTC", "BTC"] }

  def type_name
    type.gsub(/Transfer$/, "").underscore.gsub(/\_/, " ").titleize
  end

  state_machine do
    state :pending
    state :processed

    event :process do
      transitions :to => :processed,
        :from => :pending
    end
  end

  def self.from_params(params)
    transfer = class_for_transfer(params[:transfer_type]).new(params)
   
    if transfer.amount
      transfer.amount = -transfer.amount.abs 
    end
    
    transfer
  end

  def round_amount
    unless amount.nil? || amount.zero?
      self.amount = self.class.round_amount(amount, currency)
    end
  end

  def self.minimal_amount_for(transfer_type)
    transfer_type = transfer_type.to_s.downcase

    case transfer_type
      when 'wire'
        BigDecimal("30.0")
      when 'okpay'
        BigDecimal("5.0")
      when 'ltc'
        BigDecimal("1.0")
      when 'btc'
        BigDecimal("0.01")
      when 'paypal'
        BigDecimal("5")
    end
  end  

  def self.round_amount(amount, currency)
    currency = currency.to_s.downcase.to_sym
    amount = amount.to_f if amount.is_a?(Fixnum)
    amount.to_d.round(2, BigDecimal::ROUND_DOWN)
  end
  
  def self.class_for_transfer(transfer_type)
    transfer_type = transfer_type.to_s.downcase

    case transfer_type
    when 'wire'
      WireTransfer
    when 'ltc'
      LitecoinTransfer
    when 'btc'
      BitcoinTransfer
    when 'paypal'
      PaypalTransfer
    when 'okpay'
      OkpayTransfer
    else
      Withdraw
    end
  end

  def self.get_fee(system, amount = 0, accur=8)
    if Transfer::FEES_PERCENT.has_key?(system)
        fee = (amount / 100 * Transfer::FEES_PERCENT[system]).abs
    end
    
    if Transfer::FEES.has_key?(system)
      fee = Transfer::FEES[system]
    end

    # => check what is bigger percent or minimum
    if Transfer::FEES.has_key?(system) and Transfer::FEES_PERCENT.has_key?(system)
      fee = [Transfer::FEES[system].abs, (amount / 100 * Transfer::FEES_PERCENT[system]).abs].max 
    end

    return fee.abs
  end

end