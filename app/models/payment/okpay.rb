require "net/http"
require "uri"

class Payment::Okpay
  attr_accessor :amount, :currency, :request, :user, :error_message
  
  def preprocess_payment
    config = YAML::load(File.read(File.join(Rails.root, "config", "okpay.yml")))[Rails.env]
    fee = 1
    amount = self.amount.to_d.round(2)
    
    if amount < 1
      @error_message = "The minimal amount is 1 #{self.currency}"
      return false
    end
    
    url = "#{self.request.protocol}#{self.request.host}"
    callback_url = "#{url}/third_party_callbacks/okpay"
    
    account_operation_pending = AccountOperationPending.new
    account_operation_pending.account = self.user
    account_operation_pending.payment_system = 'okpay'
    account_operation_pending.amount = amount
    account_operation_pending.currency = @currency
    account_operation_pending.save!
    
    fields = {}
    fields['ok_receiver'] = config['okpayid']
    fields['ok_currency'] = @currency.upcase
    fields['ok_invoice'] = account_operation_pending.id
    fields['ok_fees'] = 1
    fields['ok_item_1_name'] = "Deposit at TradeBitcoin #{self.user.name}"
    fields['ok_item_1_price'] = @amount
    fields['ok_ipn'] = callback_url
    fields['ok_return_success'] = url
    fields['ok_return_fail'] = url
    
    return fields
  end
  
  # Call after callback
  def process_payment(params, request)

    if !params['ok_invoice'].nil? && params['ok_txn_status'] == 'completed'
      account_operation_pending = AccountOperationPending.find_by_id(params['ok_invoice'])      

      
      #params_confirm = request.POST
      #params_confirm['ok_verify'] = 'true'
      params_confirm = {'ok_verify' => 'true'}.merge(request.POST)
      
      if !account_operation_pending.nil? && params['ok_txn_net'].to_f == account_operation_pending.amount.to_f && params['ok_txn_currency'].upcase == account_operation_pending.currency.upcase

        uri = URI.parse("https://www.okpay.com/ipn-verify.html")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(params_confirm)
        
        response = http.request(request)


        if response.body == 'VERIFIED' || response.body == 'TEST'

          Operation.transaction do
            o = Operation.create
            o.currency = account_operation_pending.currency.upcase
            
            @record = AccountOperation.new do |a|
              a.amount = account_operation_pending.amount.to_f
              a.currency = account_operation_pending.currency.upcase
              a.account_id = account_operation_pending.account_id
              a.transaction_id = params['ok_txn_id']
              a.payment_system = 'Okpay'
              a.operation_type = 'deposit'
            end
          
            o.account_operations << @record
          
            o.account_operations << AccountOperation.new do |a|
              a.amount = account_operation_pending.amount.to_f * -1
              a.currency = account_operation_pending.currency.upcase
              a.account = Account.storage_account_for(account_operation_pending.currency.upcase)
            end
          
            o.save!
            account_operation_pending.delete
          end
        end        
      end
    end
  end
end
