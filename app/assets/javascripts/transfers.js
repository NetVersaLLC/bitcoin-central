function transfers()
{
    var self = this;
    this.init = function() {
        $('#transfer_transfer_type').change(function(){
            self.updateWithdrawForm();
        });
        
         $('#transfer_bank_account_id').change(function(){
            self.getFeeCall();
        });
        
        $('#transfer_currency').change(function(){
            self.updateCurrency();
            });
        
        $('#transfer_bank_type').change(function(){
            setTimeout(function(){
                self.calculateFee();
                }, 100);
            });

        $('#transfer_amount').keyup(function(){
            self.getFeeCall();
        });
        
        self.updateCurrency();
        self.calculateFee();
    }
    
    this.updateWithdrawForm = function() {
        var transferType = $("#transfer_transfer_type option:selected").val();
        redirectUrl = "/account/transfers/new?transfer_type=" + transferType;
        
        window.location = redirectUrl
    }
    
    this.updateCurrency = function () {
        if (typeof currentBalance != 'undefined') {
            var selectedCurrencies = $("#transfer_currency option:selected").val();
            if (!selectedCurrencies) {
                selectedCurrencies = $("#transfer_currency").val();
            }
            
            var maxAmount = currentBalance[selectedCurrencies];
            $('#max_amount').val(maxAmount);
        }
    }
    
    this.calculateFee = function () {
        var feeVal = 0;
        switch ($("#transfer_transfer_type option:selected").val()) {
            case 'Wire':
                if ($('#transfer_bank_type').val() == 'US') {
                    feeVal = fees['wire_us'];
                } else {
                    feeVal = fees['wire_international'];
                }
                break;
            case 'Okpay':
                feeVal = fees['okpay'];
                break;
            case 'Paypal':
                feeVal = fees['paypal'];
                break;
            case 'BTC':
                feeVal = fees['btc'] + ' BTC';
                break;
            case 'LTC':
                feeVal = fees['ltc'] + ' LTC';
                break; 
        }
        $('#withdrawal_fee').val(feeVal);
    }
    
    this.getFeeCall = function () {
        $.ajax({
        url: '/account/transfers/getfee',
        data: { _method:'POST', 
                'transfer_bank_account_id':  $("#transfer_bank_account_id option:selected").val(),
                'amount': $('#transfer_amount').val().replace(',', '.')
            },        
        type: 'POST'}).success(function(data){
            $('#withdrawal_fee').val(data);
        });
    }
}

var transfersObj = new transfers();
$(document).ready(function() {
    transfersObj.init();
})
