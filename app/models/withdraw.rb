class Withdraw < Transfer
	self.inheritance_column = nil

	validates :transfer_type,
            :inclusion => { :in => ['Wire', 'LTC', 'BTC', 'Okpay', 'Paypal', 'Fee'] }
end
