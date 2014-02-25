class Admin::PendingTransfersController < Admin::AdminController
  active_scaffold :account_operation do |config|
    config.actions = [:list, :show]

    config.columns = [
      :account,
      :bank_account_details,
      :amount,
      :currency,
      :address,
      :email,
      :transfer_type,
      :created_at
    ]

    config.list.columns = [
      :account,
      :amount,
      :currency,
      :transfer_type,
      :created_at
    ]

    config.action_links.add 'process_tx', 
      :label => 'Mark processed', 
      :type => :member, 
      :method => :post,
      :position => false

    config.action_links.add 'cancel_tx', 
      :label => 'Cancel',
      :type => :member,
      :method => :post,
      :position => false

    list.sorting = {:id => 'DESC'}
    
  end
  
  def conditions_for_collection
    ["state = 'pending' AND currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")})"]
  end
  
  def process_tx
    # Transfer;WireTransfer;LibertyReserveTransfer;BitcoinTransfer
    
    @record = AccountOperation.where("currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")})").
      find(params[:id])

    case @record.transfer_type
    when 'BTC'
      bitcoin_transfer = BitcoinTransfer.find(@record.id)
      bitcoin_transfer.make_withdraw
    when 'LTC'
      litecoin_transfer = LitecoinTransfer.find(@record.id)
      litecoin_transfer.make_withdraw
    else
      @record.state = 'processed'
      @record.save!
    end

    UserMailer.withdrawal_processed_notification(@record).deliver
    
    render :template => 'admin/pending_transfers/process_tx'
  end

  def cancel_tx
    @record = AccountOperation.find(params[:id])
    @user = @record.account
    
    if !@record.nil?
      AccountOperation.where(:operation_id => @record.operation_id).destroy_all
    end
    
    render :template => 'admin/pending_transfers/cancel_tx'
  end

  def send_cancel_message
    user = Account.find(params[:user_id])
    amount_currency = params[:amount_currency]
    message = params[:message]
    
    UserMailer.send_cancel_message(user, message, amount_currency).deliver
    @result = true

    render :text => ""
  end

end
