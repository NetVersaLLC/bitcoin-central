class BankAccount < ActiveRecord::Base
  include ActiveRecord::Transitions

  attr_accessible :bic, :iban, :account_holder, :currency, :bank_type

  attr_accessor :name_of_bank, :bank_adress, :benificiary_name, :swift_aba, :benificiary_adress

  belongs_to :user

  has_many :wire_transfers

  validates :bic,
    :presence => true
    # :format => { :with => /[A-Z]{6}[A-Z0-9]{2}[A-Z0-9]{0,3}/ }

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
end
