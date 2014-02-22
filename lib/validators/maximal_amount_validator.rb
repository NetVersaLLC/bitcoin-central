class MaximalAmountValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    value = value.abs
    
    balance = record.account.balance(record.currency)
    
    case record.transfer_type
    when 'Wire'      
      if record.respond_to?('bank_account')
        if record.bank_account.bank_type == 'US'
          value += Withdraw::get_fee('wire_us')
        else
          value += Withdraw::get_fee('wire_international')
        end
      end
    when 'Okpay'
      value += Withdraw::get_fee('okpay', balance)
    when 'Paypal'
      value += Withdraw::get_fee('paypal', balance)
    when 'BTC'
      value += Withdraw::get_fee('btc')
    end
      
    if record.new_record? and value  and record.account.is_a?(User) and (value.to_f > balance.to_f)
      record.errors[field] << (I18n.t "errors.messages.max_amount", :maximum => balance, :currency => record.currency)
    end
  end
end
