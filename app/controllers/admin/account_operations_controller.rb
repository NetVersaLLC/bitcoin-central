class Admin::AccountOperationsController < Admin::AdminController
  before_filter :set_label
  
  active_scaffold :account_operation do |config|
    config.actions.exclude :update, :delete
    
    config.columns = [:account, :amount, :currency, :bt_tx_confirmations, :type, :comment, :transaction_id, :bt_tx_id, :created_at]
    

    config.list.columns = [:created_at, :amount, :currency, :operation_type]
    config.show.columns = [:amount, :currency, :bt_tx_confirmations, :operation_type, :comment, :transaction_id, :bt_tx_id, :created_at]
     
    config.create.columns = [:amount, :currency, :comment]
    
    config.columns[:comment].form_ui = :textarea

    config.list.sorting = {:id => :desc}
  end
    
  def create
    @record = AccountOperation.new
    
    if current_user.allowed_currencies.include?(params[:record][:currency].downcase.to_sym)
      Operation.transaction do
        o = Operation.create
      
        @record = AccountOperation.new do |a|
          a.amount = BigDecimal(params[:record][:amount])
          a.currency = params[:record][:currency]
          a.account_id = params[:user_id]
          a.comment = params[:record][:comment]
        end
      
        o.account_operations << @record
      
        o.account_operations << AccountOperation.new do |a|
          a.amount = -BigDecimal(params[:record][:amount])
          a.currency = params[:record][:currency]
          a.account = Account.storage_account_for(params[:record][:currency])
        end
      
        o.save!
      end
    else
      @record.errors[:base] << t("errors.messages.insufficient_privileges")
      self.successful = false
    end
    
    respond_to_action(:create)
  end
  
  def conditions_for_collection
    ["account_id = ?", params[:user_id]]
  end
  
  def set_label
    account = Account.find(params[:user_id])
    active_scaffold_config.label = "#{account.name} (#{account.email})"
  end
end
