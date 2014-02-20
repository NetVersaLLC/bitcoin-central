class BankAccount < ActiveRecord::Base
  include ActiveRecord::Transitions

  attr_accessible :bic, :iban, :account_holder, :currency, :bank_type

  attr_accessor :name_of_bank, :bank_adress, :benificiary_name, :swift_aba, :benificiary_adress

  belongs_to :user

  has_many :wire_transfers

  validates :bic,
    :presence => true
    # :format => { :with => /[A-Z]{6}[A-Z0-9]{2}[A-Z0-9]{0,3}/ }

  validate :check_account_holder

  validates :iban,
    :presence => true
    # :iban => true

  validates :currency,
    :presence => true,
    :inclusion => { :in => ["USD", "EUR"] }

  validates :bank_type,
    #:presence => true,
    :inclusion => { :in => ["US", "International"] }
    
  validates :account_holder,
    :presence => true

  state_machine do
    state :unverified
    state :verified

    event :verify do
      transitions :to => :verified, :from => :unverified
    end
  end

  def iban
    IBANTools::IBAN.new(super).prettify
  end

  def to_label
    iban
  end

  # validate virtual attributes in BankAccountController: create
  def self.init_account_holder(params)  
    account_holder = ""
    account_holder << "name_of_bank:" << params[:name_of_bank] if params[:name_of_bank] != ""
    account_holder << ";bank_adress:" << params[:bank_adress] if params[:bank_adress] != ""
    account_holder << ";benificiary_name:" << params[:benificiary_name] if params[:benificiary_name] != ""
    account_holder << ";swift_aba:" << params[:swift_aba] if params[:swift_aba] != ""
    account_holder << ";benificiary_adress" << params[:benificiary_adress] << ";" if params[:benificiary_adress] != "" 
    account_holder
  end

  private 

  def check_account_holder
    if account_holder == ""
      errors.add("All fields", "are required")
    end
  end

end
