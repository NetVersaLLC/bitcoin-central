(function ($) {

    Tradebitcoin.views.forms.Order = Backbone.View.extend({

        initialize: function(options) {
            this.setElement(document.getElementById(options.id));
            this.$el.find(".trigger-total-update").bind("click keypress keyup blur", $.proxy(this._updateTotal, this));
        },

        _updateTotal: function() {
            precision = 4;
            ppc = parseFloat(this.$el.find(".trade-order-amount").val());
            amount = parseFloat(this.$el.find(".ppc").val());
            total = roundTo(ppc * amount, precision);
            total = !isNaN(total) ? (total.toFixed(precision).replace(/0+$/, '').replace(/\.$/, '')) : "";
            this.$el.find(".total").val(total);
        }


    });

})(jQuery);