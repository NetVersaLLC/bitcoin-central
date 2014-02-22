//= require jquery/jquery.min
//= require jquery-ujs/src/rails
//= require json2/json2
//= require underscore/underscore-min
//= require backbone/backbone-min
//= require bootstrap-sass/js/bootstrap-dropdown
//= require bootstrap-sass/js/bootstrap-tab
//= require bootstrap/js/bootstrap-modal
//= require accounts
/* fixme: include for admin area only */
//= require active_scaffold


var Tradebitcoin = Tradebitcoin || { models: {}, views: {forms: {}}};

function roundTo(value, precision) {
    return((Math.round(value * Math.pow(10, precision))) / Math.pow(10, precision))
}

function deprecated() {

    $(document).ready(function() {
        /* Trade order creation form */
        $("body.trade_orders input.trigger-total-update").bind("click keypress keyup blur", updateTotal)

        if ($("body.trade_orders input#trade_order_amount").length) {
            updateTradeOrderForm()
        }

        // Triggered by a currency or category selection on
        // the trade order creation form
        $("body.trade_orders select.trigger-total-update").change(updateTradeOrderForm)

        $("body.transfers-new #transfer_currency").change(updateWithdrawForm)

        /* Logout count-down */
        $("span#countdown").show()

        delay = $('#countdown').data("delay")
        logoutPath = $('#countdown').data("logout-path")

        var logout = new Date()
        logout.setSeconds(logout.getSeconds() + delay)

        $('#countdown').countdown({
            until: logout,
            compact: true,
            format: "%M:%S",
            layout: "({mnn}:{snn})",
            onExpiry: function() {
                window.location = logoutPath
            }
        })

        $("#trade_order_type").change(updateDisplayedFields)

        if ($("#trade_order_type")) {
          updateDisplayedFields()
        }

        // QR code fancybox next to address
        $("a.address-qrcode").fancybox({
          opacity: true,
          showCloseButton: true
        })
    })

    function updateTradeOrderForm() {
        currency = getSelectedCurrency();
        category = $("input:radio.category-select:checked").val()

        if (category) {
            if (category == "sell") {
                setBalance("BTC")
            }
            else {
                if (currency) {
                    setBalance(currency)
                }
                else {
                    $("#balance").val("")
                }
            }
        }

        updateTotal();
    }

    function getSelectedCurrency() {
        return($("select.currency-select").val());
    }

    function setBalance(currency) {
        $.get("/account/balance/" + currency + ".json", {},
          function(data) {
            $("#balance").val(data.balance + " " + data.currency)
          }
        )
    }

    function updateTotal() {
        precision = 5
        currency = getSelectedCurrency()
        ppc = parseFloat($("#trade_order_ppc").val())
        amount = parseFloat($("#trade_order_amount").val())
        total = roundTo(ppc * amount, precision)

        if (!isNaN(total)) {
            total = (total.toFixed(precision).toString())

            if (currency) {
                total = total + " " + currency
            }
        }
        else {
            total = ""
        }

        $("#total").val(total)
    }

    function updateWithdrawForm(evt) {
       currency = evt.target.options[evt.target.selectedIndex].value
       window.location = "/account/transfers/new?currency=" + currency
    }



    function updateDisplayedFields() {
      if ($("#trade_order_type").val() == "limit_order") {
        $("#trade_order_ppc").parent("div").show()
        $("#total").parent("div").show()
      }
      else if ($("#trade_order_type").val() == "market_order") {
        $("#trade_order_ppc").parent("div").hide()
        $("#total").parent("div").hide()
      }
    }

}
