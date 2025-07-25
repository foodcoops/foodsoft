class GroupOrderForm {
  constructor(form$, config) {
    this.form$ = form$;
    this.articleRows$ = this.form$.find('tr.order-article');
    this.totalPrice$ = this.form$.find('#total_price');
    this.newBalance$ = this.form$.find('#new_balance');
    this.totalBalance$ = this.form$.find('#total_balance');
    this.submitButton$ = this.form$.find('#submit_button');
    this.units = config.units;
    this.toleranceIsCostly = config.toleranceIsCostly;
    this.groupBalance = config.groupBalance;
    this.minimumBalance = config.minimumBalance;

    this.initializeIncreaseDecreaseButtons();
    this.submitButton$.removeAttr('disabled');
  }

  initializeIncreaseDecreaseButtons() {
    this.articleRows$.each((_, element) => this.initializeOrderArticleRow($(element)));
  }

  initializeOrderArticleRow(row$) {
    const quantity$ = row$.find('.goa-quantity');
    const tolerance$ = row$.find('.goa-tolerance');
    // eslint-disable-next-line no-undef
    const quantityAndTolerance$ = mergeJQueryObjects([quantity$, tolerance$]);
    // eslint-disable-next-line no-undef
    quantityAndTolerance$.each((_, element) => $(element).unitConversionField({
      units: this.units,
      popoverTemplate$: $('#unit_conversion_popover_content_template'),
    }));
    row$.find('.btn-ordering').mousedown((e) => e.preventDefault());
    row$.find('.btn-ordering.decrease').click((event) => this.increaseOrDecrease($(event.target).parents('.btn-group').find('input.numeric'), false));
    row$.find('.btn-ordering.increase').click((event) => this.increaseOrDecrease($(event.target).parents('.btn-group').find('input.numeric'), true));

    quantityAndTolerance$.change(() => {
      this.updateMissingUnits(row$, quantity$);
      this.updateBalance();
    });
    quantityAndTolerance$.keyup(() => quantity$.trigger('change'));
  }

  updateBalance() {
    const total = this.articleRows$
      .toArray()
      .reduce((acc, row) =>
        Big(acc).add(parseFloat($(row).find('*[id^="price_"][id$="_display"]').data('price'))).toNumber(),
        0
      );

    this.totalPrice$.text(I18n.l('currency', total));
    const balance = Big(this.groupBalance).sub(total).toNumber();
    this.newBalance$.text(I18n.l('currency', balance));

    // TODO: Figure out why this hidden field is required (Should be
    // calculated in the controller IMO! - see https://github.com/foodcoopsat/foodsoft_hackathon/issues/97):
    this.totalBalance$.val(I18n.l('currency', balance));

    // determine bgcolor and submit button state according to balance
    var bgcolor = '';
    if (balance < this.minimumBalance) {
        bgcolor = '#FF0000';
        this.submitButton$.attr('disabled', 'disabled')
    } else {
      this.submitButton$.removeAttr('disabled')
    }

    // update bgcolor
    this.articleRows$.find('*[id^="td_price_"]').css('background-color', bgcolor);
  }

  increaseOrDecrease(field$, increase) {
    let step = parseFloat(field$.attr('step'));
    if (isNaN(step)) {
      step = 1;
    }
    if (!increase) {
      step *= -1;
    }
    let value = parseFloat(field$.val());

    if (isNaN(value)) {
      value = 0;
    }

    value = round(value + step);
    let remainder = round(value % step);
    if (remainder !== 0) {
      if (!increase) {
        remainder *= -1;
      }
      value += remainder - step;
    }
    const min = field$.attr('min');
    if (min !== undefined) {
      value = Math.max(parseFloat(min), value);
    }

    const max = field$.attr('max');
    if (max !== undefined) {
      value = Math.min(parseFloat(max), value);
    }

    field$.val(value);
    field$.trigger('change');
  }

  updateMissingUnits(row$) {
    const used$ = row$.find('.used-unused .used');
    const unused$ = row$.find('.used-unused .unused');

    const quantity$ = row$.find('.goa-quantity');
    const tolerance$ = row$.find('.goa-tolerance');
    const usedTolerance$ = row$.find('.used-unused-tolerance .used');
    const unusedTolerance$ = row$.find('.used-unused-tolerance .unused');
    const totalPacks$ = row$.find('.article-info *[id^="units_"]');
    const totalQuantity$ = row$.find('.article-info *[id^="q_total_"]');
    const totalTolerance$ = row$.find('.article-info *[id^="t_total_"]');
    const totalPrice$ = row$.find('*[id^="price_"][id$="_display"]');

    const missing$ = row$.find('.missing-units');

    let quantity = parseFloat(quantity$.val().trim().replace(',', '.'));
    if (isNaN(quantity)) {
      quantity = 0;
    }
    const granularity = parseFloat(quantity$.attr('step'));
    let tolerance = tolerance$.length === 1 ? parseFloat(tolerance$.val().trim().replace(',', '.')) : 0;
    if (isNaN(tolerance)) {
      tolerance = 0;
    }
    const supplierOrderUnit = quantity$.data('supplier-order-unit');
    const converter = quantity$.unitConversionField('getConverter');
    const packSizeDeterminedBySupplierOrderUnit = converter && !converter.isUnitSiConversible(supplierOrderUnit);

    const packSize = packSizeDeterminedBySupplierOrderUnit ? parseFloat(quantity$.data('ratio-group-order-unit-supplier-unit')) : 0.001;
    const othersQuantity = parseFloat(quantity$.data('others-quantity'));
    const othersTolerance = parseFloat(quantity$.data('others-tolerance'));
    const usedQuantity = parseFloat(quantity$.data('used-quantity'));
    const minimumOrderQuantity = parseFloat(quantity$.data('minimum-order-quantity'));
    const price = parseFloat(quantity$.data('price'));

    const totalQuantity = Big(quantity).add(othersQuantity).toNumber();
    const totalTolerance = Big(tolerance).add(othersTolerance).toNumber();

    const totalPacks = this.calculatePacks(packSize, totalQuantity, totalTolerance, minimumOrderQuantity)

    const totalPrice = Big(price).mul(Big(quantity).add(this.toleranceIsCostly ? tolerance : 0)).toNumber();

    // update used/unused quantity
    const available = Math.max(0, Big(totalPacks).mul(packSize).sub(othersQuantity).toNumber());
    let used = Math.min(available, quantity);
    // ensure that at least the amount of items this group has already been allocated is used
    if (quantity >= usedQuantity && used < usedQuantity) {
      used = usedQuantity;
    }

    const unused = Big(quantity).sub(used).toNumber();

    const availableForTolerance = quantity < minimumOrderQuantity ? Big(minimumOrderQuantity).sub(quantity).toNumber() : Math.max(0, Big(available).sub(used).sub(othersTolerance).toNumber());
    const usedTolerance = Math.min(availableForTolerance, tolerance);
    const unusedTolerance = Big(tolerance).sub(usedTolerance).toNumber();

    const missing = this.calcMissingItems(packSize, totalQuantity, totalTolerance, minimumOrderQuantity);

    used$.text(round(used));
    unused$.text(round(unused));

    usedTolerance$.text(round(usedTolerance));
    unusedTolerance$.text(round(unusedTolerance));

    totalPacks$.text(packSizeDeterminedBySupplierOrderUnit ? round(totalPacks) : round(totalQuantity));

    totalPacks$.css('color', this.packCompletedFromTolerance(packSize, totalQuantity, totalTolerance) ? 'grey' : 'auto');

    totalQuantity$.text(round(totalQuantity));
    totalTolerance$.text(round(totalTolerance));
    totalPrice$.text(I18n.l('currency', round(totalPrice)));
    totalPrice$.data('price', round(totalPrice));

    missing$.text(round(missing));
    if (tolerance$.length === 1) {
      this.setRowStyle(row$, missing, granularity, quantity);
    }
  }

  setRowStyle(row$, missing, granularity, quantity) {
    row$.removeClass('missing-many missing-few missing-none');
    if (missing === 0) {
      if (quantity !== 0) {
        row$.addClass('missing-none');
      }
    } else {
      row$.addClass(missing <= granularity ? 'missing-few' : 'missing-many');
    }
  }

  calculatePacks(packSize, quantity, tolerance, minimumOrderQuantity) {
    if (Big(quantity).add(tolerance).toNumber() < minimumOrderQuantity) {
      return 0;
    }

    const used = Big(quantity).div(packSize).round(0, Big.roundDown).toNumber();
    const remainder = Big(quantity).mod(packSize).toNumber();
    return Big(used).add((remainder > 0) && (Big(remainder).add(tolerance).toNumber() >= packSize) ? 1 : 0).toNumber();
  }

  calcMissingItems(packSize, quantity, tolerance, minimumOrderQuantity) {
    if (quantity !== 0 && Big(quantity).add(tolerance).toNumber() < minimumOrderQuantity) {
      return Big(minimumOrderQuantity).sub(quantity).sub(tolerance).toNumber();
    }

    if (isNaN(quantity)) {
      return quantity;
    }

    if (isNaN(packSize)) {
      return packSize;
    }

    var remainder = Big(quantity).mod(packSize).toNumber();
    return remainder > 0 && Big(remainder).add(tolerance).toNumber() < packSize ? Big(packSize).sub(remainder).sub(tolerance).toNumber() : 0
  }

  packCompletedFromTolerance(packSize, quantity, tolerance) {
    var remainder = Big(quantity).mod(packSize).toNumber();
    return (remainder > 0 && (Big(remainder).add(tolerance).toNumber() >= packSize));
  }
}

