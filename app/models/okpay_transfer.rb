class OkpayTransfer < Withdraw
  attr_accessible :address

	VALID_ADDRESS_REGEX=/^[o][k][0-9]{9}$/i
 	validates :address, 
            :presence => true, 
  		      :length => { :is => 11 }, 
  		      :format => { :with => VALID_ADDRESS_REGEX }

  validates :currency,
    :inclusion => { :in => ["USD", "EUR", "BTC"] }

  def execute
  	# Placeholder for now
  end
end
