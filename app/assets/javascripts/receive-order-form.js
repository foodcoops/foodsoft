(function ( $ ) {
  class ReceiveOrderForm {
    constructor(receiveForm$, packageHelperIcon, newOrderArticlePath) {
      this.receiveForm$ = receiveForm$;
      this.packageHelperIcon = packageHelperIcon;
      this.newOrderArticlePath = newOrderArticlePath;
      $(document).on('change keyup', 'input[data-units-expected]', (e) => {
        this.updateDelta(e.target);
      });

      $(document).on('touchclick', '#order_articles .unlocker', (e) => this.unlockReceiveInputField($(e.target)));

      $(document).on('click', '#set_all_to_zero', () => {
        $('tbody input').each((_, input) => {
          $(input).val(0);
          this.updateDelta(input);
        });
      });

      $('input[data-units-expected]').each((_, field) => {
        this.convertToBillingUnit($(field));
        this.updateDelta(field);
      });

      this.receiveForm$.submit(() => {
        $('input[data-units-expected]').each((_, field) => {
          this.convertFromBillingUnit($(field));
        });
      });

      this.initAddArticle('#add_article');
    }

    convertFieldUnit(field$, fromUnit, toUnit) {
      if (field$.is(':disabled')) {
        return;
      }

      const units = parseFloat(field$.val().replace(',', '.'));
      if (isNaN(units)) {
        return;
      }

      const converter = field$.unitConversionField('getConverter');
      if (converter === undefined) {
        return units;
      }
      return converter.getUnitRatio(units, fromUnit, toUnit);
    }

    convertToBillingUnit(field$) {
      const val = this.convertFieldUnit(field$, field$.data('supplier-order-unit'), field$.data('billing-unit'));
      field$.val(val === undefined ? '' : round(val));
    }

    convertFromBillingUnit(field$) {
      const convertedValue = this.convertFieldUnit(field$, field$.data('billing-unit'), field$.data('supplier-order-unit'));
      if (convertedValue !== undefined) {
        const hiddenReceivedField$ = $(`<input type="hidden" name="${field$.attr('name')}" value="${convertedValue}" />`);
        this.receiveForm$.append(hiddenReceivedField$);
      }
    }

    updateDelta(input) {
      const units = $(input).val().replace(',', '.');
      const expected = $(input).data('units-expected');
      const delta = round(units-expected);
      let html;

      if (units.replace(/\s/g,"")=="") {
        // no value
        html = '';
      } else if (isNaN(units)) {
        html = '<i class="icon-remove" style="color: red"></i>';
      } else if (delta == 0) {
        // equal value
        html = '<i class="icon-ok" style="color: green"></i>';
      } else {
        if (delta < 0) {
          html = '<span style="color: red">- '+(-delta)+'</span>';
        } else /*if (units> expected)*/ {
          html = '<span style="color: green">+ '+(delta)+'</span>';
        }
        // show package icon only if the receive field has one
        if ($(input).hasClass('package')) {
          html += this.packageHelperIcon;
        }
      }

      $(input).closest('tr').find('.units_delta').html(html);

      // un-dim row when received is nonzero
      $(input).closest('tr').toggleClass('unavailable', expected == 0 && html=='');
    }


    replace(id, newRow$) {
      const oldRow$ = this.receiveForm$.find(`#order_article_${id}`);
      const oldField$ = oldRow$.find('input.units_received')
      const currentValue = oldField$.val();
      oldRow$.replaceWith(newRow$);
      const newField$ = newRow$.find('input.units_received');
      newField$.val(currentValue);
      newField$.unitConversionField(oldField$.unitConversionField('getConversionField'));
      this.updateDelta(newField$);
    }


    initAddArticle(sel) {
      $(sel).removeAttr('disabled').select2({
        placeholder: I18n.t('orders.receive.add_article'),
        formatNoMatches: () =>  I18n.t('no_articles_available')
        // TODO implement adding a new article, like in deliveries
      }).on('change', (e) => {
        var $input = $(e.target);
        var selectedArticleId = $input.val();
        if(!selectedArticleId) {
          return false;
        }

        $.ajax({
          url: this.newOrderArticlePath,
          type: 'post',
          data: JSON.stringify({order_article: {article_version: {article_id: selectedArticleId}}}),
          contentType: 'application/json; charset=UTF-8'
        });

        $input.val('').trigger('change');
      });
      $(sel).val('').trigger('change');
    }

    unlockReceiveInputField(unlockButton$) {
      $('.units_received', unlockButton$.closest('tr')).prop('disabled', false).focus();
      unlockButton$.closest('.input-prepend').prop('title', I18n.t('orders.edit_amount.field_unlocked_title'));
      unlockButton$.replaceWith('<i class="icon icon-warning-sign"></i>');
    }
  }

  const receiveOrderFormsMap = new Map();

  $.fn.receiveOrderForm = function (options, actionOptions) {
    switch(options) {
      case 'replace': {
        const receiveOrderForm = receiveOrderFormsMap.get($(this)[0]);
        receiveOrderForm.replace(actionOptions.id, actionOptions.newEntry);
        break;
      }
      default: {
        const receiveOrderForm = new ReceiveOrderForm($(this), options.packageHelperIcon, options.newOrderArticlePath);
        receiveOrderFormsMap.set($(this)[0], receiveOrderForm);
        break;
      }
    }

    return this;
  };

}( jQuery ));
