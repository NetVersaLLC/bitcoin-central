class TransfersController < ApplicationController
  layout 'account'
  respond_to :html, :json

  def index
    @transfers = current_user.account_operations.order("id desc").paginate(:page => params[:page], :per_page => 16)
    respond_with @transfers
  end

  def new
    @balance = {:USD => @current_user.balance('USD') || '0', 
                :EUR => @current_user.balance('EUR') || '0', 
                :LTC => @current_user.balance('LTC') || '0', 
                :BTC => @current_user.balance('BTC') || '0'}

    params[:transfer_type] = params[:transfer_type] || "BTC"

    case params[:transfer_type]
      when 'Wire'
        @transfer = WireTransfer.new(:transfer_type => params[:transfer_type])
        @transfer.build_bank_account
        fetch_bank_accounts

      when 'BTC'
        @transfer = Withdraw.new(:transfer_type => "BTC")
        # @transfer.address = params[:address] || current_user.btc_address_external

      # => Don't work
      when 'Paypal'
        @transfer =  Withdraw.new(:transfer_type => "Paypal")

      when 'Okpay'
        @transfer =  Withdraw.new(:transfer_type => "Okpay") 
    end 
  end
  
  def show
    @transfer = current_user.account_operations.find(params[:id])
    respond_with @transfer
  end
  
  def create
    @balance = {:USD => @current_user.balance('USD') || '0', 
                :EUR => @current_user.balance('EUR') || '0', 
                :LTC => @current_user.balance('LTC') || '0', 
                :BTC => @current_user.balance('BTC') || '0'}

    params[:transfer][:amount] = params[:transfer][:amount].to_f

    @transfer = Withdraw.from_params(params[:transfer])
    @transfer.account = current_user
    @transfer.operation_type = 'withdrawal'
    
    if @transfer.is_a?(WireTransfer) && @transfer.bank_account
      @transfer.bank_account.user_id = current_user.id
      @transfer.bank_account.currency = @transfer[:currency]

      #If bank account is already stored
      if !params[:transfer][:bank_account_id]
        @transfer.bank_account.bank_type = params[:transfer][:bank_type]
      end
    end

    transfer_fee = 0
    
    case @transfer.transfer_type
    when 'Wire'
      if !@transfer.bank_account.nil?
        
        # get_fee(bank_type, amount)
        transfer_fee = Withdraw::get_fee(
                  'wire_' + @transfer.bank_account.bank_type.downcase, 
                  @transfer.amount)
        
        # => W
        # => @transfer.transfer_type = 'Wire'
      else # Bank account is not seleted
        fetch_bank_accounts
        render :action => :new and return
      end
    #when 'Popmoney'
    #  transfer_fee = Withdraw::FEES[:popmoney]
    #  @transfer.transfer_type = 'Popmoney'
    when 'BTC'
      # => @transfer.transfer_type = 'BTC'
      transfer_fee = Withdraw::get_fee('btc')
    when 'Okpay'
      transfer_fee = Withdraw::get_fee('okpay', @transfer.amount)
      # => @transfer.transfer_type = 'Okpay'
    when 'Paypal'
      transfer_fee = Withdraw::get_fee('paypal', @transfer.amount)      
      # => @transfer.transfer_type = 'Paypal'      
    when 'LTC'
      transfer_fee = Withdraw::get_fee('ltc')
      # => @transfer.transfer_type = 'LTC'
    end

    Operation.transaction do
      o = Operation.create!
      o.account_operations << @transfer
      o.account_operations << AccountOperation.new do |ao|
        ao.amount = @transfer.amount && @transfer.amount.abs
        ao.currency = @transfer.currency
        ao.account = Account.storage_account_for(@transfer.currency)
      end

      #Withdrawal fee
      if transfer_fee > 0
        ao_fee = Fee.new
        ao_fee.amount = transfer_fee * -1
        ao_fee.account = current_user
        ao_fee.operation_id = o.id
        ao_fee.currency = @transfer.currency
        ao_fee.transfer_type = 'Fee'
        ao_fee.operation_type = 'fee'
        ao_fee.save
        
        ao_fee = Fee.new
        ao_fee.amount = transfer_fee.abs
        ao_fee.account = Account.storage_account_for(@transfer.currency)
        ao_fee.operation_id = o.id
        ao_fee.currency = @transfer.currency
        ao_fee.transfer_type = 'Fee'
        ao_fee.save
      end

      raise(ActiveRecord::Rollback) unless o.save
    end

    unless @transfer.new_record?
      respond_with do |format|
        format.html do
          redirect_to account_transfers_path,
            :notice => I18n.t("transfers.index.successful.#{@transfer.state}", :amount => @transfer.amount.abs, :currency => @transfer.currency)
        end
          
        format.json { render :json => @transfer }
      end
    else
      fetch_bank_accounts
      render :action => :new
    end
  end
  
  def getfee
    bank_account = current_user.bank_accounts.find(params[:transfer_bank_account_id])
    amount = params[:amount].to_f || nil
    if bank_account.bank_type == 'US'
        transfer_fee = Withdraw::get_fee('wire_us', amount)
    else
        transfer_fee = Withdraw::get_fee('wire_international', amount)
    end
    
    render :text => transfer_fee
  end

  protected
  
  def fetch_bank_accounts
    @bank_accounts = current_user.bank_accounts.map { |ba| ["#{ba.iban}", ba.id] }.insert(0, "---")
  end
end