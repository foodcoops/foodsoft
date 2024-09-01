class ArticleForm {
  constructor(articleUnitRatioTemplate$, articleForm$, units, priceMarkup, multiForm$, unitFieldsIdPrefix, unitFieldsNamePrefix) {
    try {
      this.units = units;
      this.priceMarkup = priceMarkup;
      this.unitFieldsIdPrefix = unitFieldsIdPrefix === undefined ? 'article_version' : unitFieldsIdPrefix;
      this.unitFieldsNamePrefix = unitFieldsNamePrefix === undefined ? this.unitFieldsIdPrefix : unitFieldsNamePrefix;
      this.articleUnitRatioTemplate$ = articleUnitRatioTemplate$;
      this.articleForm$ = articleForm$;
      this.unitConversionPopoverTemplate$ = $('#unit_conversion_popover_content_template');
      this.unit$ = $(`#${this.unitFieldsIdPrefix}_unit`, this.articleForm$);
      this.customUnitWarning$ = $('.icon-warning-sign', this.articleForm$);
      this.supplierUnitSelect$ = $(`#${this.unitFieldsIdPrefix}_supplier_order_unit`, this.articleForm$);
      this.unitRatiosTable$ = $('#fc_base_price', this.articleForm$);
      this.minimumOrderQuantity$ = $(`#${this.unitFieldsIdPrefix}_minimum_order_quantity`, this.articleForm$);
      this.maximumOrderQuantity$ = $(`#${this.unitFieldsIdPrefix}_maximum_order_quantity`, this.articleForm$);
      this.billingUnit$ = $(`#${this.unitFieldsIdPrefix}_billing_unit`, this.articleForm$);
      this.groupOrderGranularity$ = $(`#${this.unitFieldsIdPrefix}_group_order_granularity`, this.articleForm$);
      this.groupOrderUnit$ = $(`#${this.unitFieldsIdPrefix}_group_order_unit`, this.articleForm$);
      this.price$ = $(`#${this.unitFieldsIdPrefix}_price`, this.articleForm$);
      this.priceUnit$ = $(`#${this.unitFieldsIdPrefix}_price_unit`, this.articleForm$);
      this.tax$ = $(`#${this.unitFieldsIdPrefix}_tax`, this.articleForm$);
      this.deposit$ = $(`#${this.unitFieldsIdPrefix}_deposit`, this.articleForm$);
      this.fcPrice$ = $(`#article_fc_price`, this.articleForm$);
      this.unitsToOrder$ = $('#order_article_units_to_order', this.articleForm$);
      this.unitsReceived$ = $('#order_article_units_received', this.articleForm$);
      this.toggleExtraUnitsButton$ = $('.toggle-extra-units', this.articleForm$);
      this.extraUnits$ = $('.extra-unit-fields', this.articleForm$);
      this.submitButton$ = $('input[type="submit"]', this.articleForm$);
      this.multiForm$ = multiForm$;
      const selectContainer$ = this.articleForm$.parents('#modalContainer');
      this.select2Config = {
        dropdownParent: selectContainer$.length === 0 ? undefined : selectContainer$
      };

      this.loadAvailableUnits();
      this.initializeRegularFormFields();

      this.initializeRatioRows();
      this.bindAddRatioButton();

      this.setFieldVisibility();

      this.loadRatios();
      this.prepareRatioDataForSequentialRepresentation();
      this.convertPriceToPriceUnit();
      this.initializePriceDisplay();
      this.initializeOrderedAndReceivedUnits();
      this.convertOrderedAndReceivedUnits(this.supplierUnitSelect$.val(), this.billingUnit$.val());
      this.initializeFormSubmitListener();
      this.initializeToggleExtraUnitsButton();
      this.enableSubmitButton();
    } catch (e) {
      console.log('Could not initialize article form', e, 'articleUnitRatioTemplate$', articleUnitRatioTemplate$, 'articleForm$', articleForm$, 'units', units, 'priceMarkup', priceMarkup, 'multiForm$', multiForm$, 'unitFieldsIdPrefix', unitFieldsIdPrefix, 'unitFieldsNamePrefix', unitFieldsNamePrefix);
    }
  }

  initializePriceDisplay() {
    mergeJQueryObjects([this.price$, this.priceUnit$, this.tax$, this.deposit$]).on('change keyup', () => {
      const price = parseFloat(this.price$.val());
      const tax = parseFloat(this.tax$.val());
      const deposit = parseFloat(this.deposit$.val());
      const grossPrice = (price + deposit) * (tax / 100 + 1);
      const fcPrice = grossPrice  * (this.priceMarkup / 100 + 1);
      const priceUnitLabel = this.getUnitLabel(this.priceUnit$.val());
      this.fcPrice$.find('.price_value').text(isNaN(fcPrice) ? '?' : I18n.l('currency', fcPrice));
      this.fcPrice$.find('.price_per_text').toggle(priceUnitLabel.trim() !== '');
      this.fcPrice$.find('.price_unit').text(priceUnitLabel);
    });

    this.price$.trigger('change');
  }

  getUnitLabel(unitKey) {
    if (unitKey === '') {
      return this.unit$.val();
    }
    const unit = this.availableUnits.find((availableUnit) => availableUnit.key === unitKey);
    if (unit === undefined) {
      return '?';
    }
    return unit.symbol != null ? unit.symbol : unit.label;
  }

  initializeFormSubmitListener() {
    (this.multiForm$ === undefined ? this.articleForm$ : this.multiForm$).submit((e) => {
      try {
        this.undoSequentialRatioDataRepresentation();
        this.loadRatios();
        this.undoPriceConversion();
        this.undoOrderAndReceivedUnitsConversion();
      } catch(err) {
        e.preventDefault();
        throw err;
      }
    });
  }

  initializeToggleExtraUnitsButton() {
    if (this.toggleExtraUnitsButton$.length > 0) {
      this.setExtraUnitsButtonStatus();

      this.toggleExtraUnitsButton$.on('click', (e) => {
        this.toggleExtraUnits();
      });

      this.supplierUnitSelect$.on('change', () => this.setExtraUnitsButtonStatus());
    }
  }

  setExtraUnitsButtonStatus() {
    if (this.hasDeviatingExtraUnits()) {
      this.toggleExtraUnitsButton$.removeClass('default-values');
    } else {
      this.toggleExtraUnitsButton$.addClass('default-values');
    }
  }

  hasDeviatingExtraUnits() {
    if ($(`input[name^="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes]"][name$="[quantity]"]`).length > 0) {
      return true;
    }

    const supplierOrderUnit = this.supplierUnitSelect$.val();
    if (supplierOrderUnit !== this.groupOrderUnit$.val() || supplierOrderUnit !== this.billingUnit$.val()) {
      return true;
    }

    if (this.minimumOrderQuantity$.val().trim() !== '' || parseFloat(this.groupOrderGranularity$.val().trim()) !== 1) {
      return true;
    }

    return false;
  }

  toggleExtraUnits() {
    this.setExtraUnitsButtonStatus();
    $(document).off('mousedown.extra-units');
    this.extraUnits$.toggleClass('show');
    this.toggleExtraUnitsButton$.toggleClass('show');

    if (this.extraUnits$.hasClass('show')) {
      $(document).on('mousedown.extra-units', (e) => {
        if ($(e.target).parents(this.extraUnits$.selector).length !== 0 || e.target === this.extraUnits$[0] || e.target === this.toggleExtraUnitsButton$[0]) {
          return;
        }

        this.toggleExtraUnits();
      });
    }
  }

  getUnitsConverter() {
    return new UnitsConverter(this.units, this.ratios, this.supplierUnitSelect$.val());
  }

  getUnitRatio(quantity, inputUnit, outputUnit) {
    const converter = this.getUnitsConverter();
    return converter.getUnitRatio(quantity, inputUnit, outputUnit);
  }

  undoPriceConversion() {
    const relativePrice = this.price$.val();
    const priceUnit = this.priceUnit$.val();
    if (priceUnit === undefined) {
      return;
    }
    const ratio = this.getUnitRatio(1, priceUnit, this.supplierUnitSelect$.val());
    const supplierUnitPrice = relativePrice / ratio;
    const hiddenPriceField$ = $(`<input type="hidden" name="${this.price$.attr('name')}" value="${supplierUnitPrice}" />`);
    this.articleForm$.append(hiddenPriceField$);
  }

  undoOrderAndReceivedUnitsConversion() {
    this.convertOrderedAndReceivedUnits(this.billingUnit$.val(), this.supplierUnitSelect$.val());
  }

  loadAvailableUnits() {
    this.availableUnits = Object.entries(this.units)
      .filter(([, unit]) => unit.visible)
      .map(([code, unit]) => {
        let label = unit.name;
        if (unit.symbol != null) {
          label += ` (${unit.symbol})`;
        }
        return { key: code, label, baseUnit: unit.baseUnit, symbol: unit.symbol, aliases: unit.aliases ? unit.aliases : [] };
      });

    $(`#${this.unitFieldsIdPrefix}_supplier_order_unit`, this.articleForm$).select2(this.select2Config);
  }

  initializeRegularFormFields() {
    this.unit$.change(() => {
      this.setMinimumOrderUnitDisplay();
      this.updateAvailableBillingAndGroupOrderUnits();
      this.updateUnitMultiplierLabels();
      this.updateCustomUnitWarning();
    });
    this.updateCustomUnitWarning();
    this.unit$.keyup(() => this.unit$.trigger('change'));


    this.supplierUnitSelect$.change(() => {
      this.onSupplierUnitChanged();
      this.updateCustomUnitWarning();
    });
    this.onSupplierUnitChanged();
  }

  updateCustomUnitWarning() {
    const supplierUnitValueChosen = this.supplierUnitSelect$.val() !== undefined && this.supplierUnitSelect$.val().trim() !== '';
    if (supplierUnitValueChosen) {
      this.customUnitWarning$.hide();
      return;
    }

    const unitVal = this.unit$.val().trim().toLowerCase();
    if (unitVal !== '' && (unitVal.match(/[0-9]/) || this.availableUnits.some((unit) => (unit.symbol != null && unit.symbol.toLowerCase() === unitVal) || unit.label.toLowerCase() === unitVal || unit.aliases.some((alias) => alias.toLowerCase() === unitVal)))) {
      this.customUnitWarning$.show();
    } else {
      this.customUnitWarning$.hide();
    }
  }

  onSupplierUnitChanged() {
    const valueChosen = this.supplierUnitSelect$.val() !== undefined && this.supplierUnitSelect$.val().trim() !== '';
    this.unit$.prop('disabled', valueChosen);
    this.unit$.toggle(!valueChosen);
    this.filterAvailableRatioUnits();
    this.setMinimumOrderUnitDisplay();
    this.updateAvailableBillingAndGroupOrderUnits();
    this.updateUnitMultiplierLabels();
  }

  setMinimumOrderUnitDisplay() {
    const chosenOptionLabel = this.supplierUnitSelect$.val() !== ''
      ? $(`option[value="${this.supplierUnitSelect$.val()}"]`, this.supplierUnitSelect$).text()
      : undefined;
    const unitVal = $(`#${this.unitFieldsIdPrefix}_unit`).val();
    this.minimumOrderQuantity$
      .parents('.input-append')
      .find('.add-on')
      .text(chosenOptionLabel !== undefined ? chosenOptionLabel : unitVal);

    const converter = this.getUnitsConverter();
    this.minimumOrderQuantity$.attr('step', converter.isUnitSiConversible(this.supplierUnitSelect$.val()) ? 'any' : 1);
  }

  bindAddRatioButton() {
    $('*[data-add-ratio]', this.articleForm$).on('click', (e) => {
      e.preventDefault();
      e.stopPropagation();

      this.onAddRatioClicked();
    });
  }

  onAddRatioClicked() {
    const newRow$ = this.articleUnitRatioTemplate$.clone();
    $('tbody', this.unitRatiosTable$).append(newRow$);

    const index = $(`input[name^="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes]"][name$="[sort]"]`, this.articleForm$).length
      + $(`input[name^="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes]"][name$="[_destroy]"]`, this.articleForm$).length;

    const sortField$ = $('[name$="[sort]"]', newRow$);
    sortField$.val(index);

    const ratioAttributeFields$ = $(`[id^="${this.unitFieldsIdPrefix}_article_unit_ratios_attributes_0_"]`, newRow$);
    ratioAttributeFields$.each((_, field) => {
      $(field).attr('name', $(field).attr('name').replace('[0]', `[${index}]`));
      $(field).attr('id', $(field).attr('id').replace(`${this.unitFieldsIdPrefix}_article_unit_ratios_attributes_0_`, `${this.unitFieldsIdPrefix}_article_unit_ratios_attributes_${index}_`));
    });

    this.setFieldVisibility();

    this.initializeRatioRows();
  }

  initializeRatioRows() {
    $('tr', this.unitRatiosTable$).each((_, row) => {
      this.initializeRatioRow($(row));
    });

    this.updateUnitMultiplierLabels();
    this.filterAvailableRatioUnits();
  }

  initializeRatioRow(row$) {
    $('*[data-remove-ratio]', row$)
      .off('click.article_form_ratio_row')
      .on('click.article_form_ratio_row', (e) => {
        e.preventDefault();
        e.stopPropagation();
        this.removeRatioRow($(e.target).closest('tr'));
      });

    const select$ = $('select[name$="[unit]"]', row$);
    select$.change(() => {
      this.filterAvailableRatioUnits(row$)
      this.updateUnitMultiplierLabels();
    });
    select$.select2(this.select2Config);
  }

  updateUnitMultiplierLabels() {
    $('tr', this.unitRatiosTable$).each((_, row) => {
      const row$ = $(row);
      const aboveUnit = this.findAboveUnit(row$);
      $('.unit_multiplier', row$).text(aboveUnit);
    });
  }

  removeRatioRow(row$) {
    const index = row$.index() + 1;
    const id = $(`[name="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes][${index}][id]"]`, this.articleForm$).val();
    row$.remove();

    if (id != null) {
      $(this.unitRatiosTable$).after($(`<input type="hidden" name="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes][${index}][_destroy]" value="true">`));
      $(this.unitRatiosTable$).after($(`<input type="hidden" name="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes][${index}][id]" value="${id}">`));
    }

    this.filterAvailableRatioUnits();
    this.updateUnitMultiplierLabels();
    this.setFieldVisibility();
  }

  filterAvailableRatioUnits() {
    const isUnitOrBaseUnitSelected = (unit, select$) => {
      const code = select$.val();
      const selectedUnit = this.units[code];
      return unit.key !== code && (!unit.baseUnit || !selectedUnit || !selectedUnit.baseUnit || unit.baseUnit !== selectedUnit.baseUnit);
    };

    let remainingAvailableUnits = this.availableUnits.filter(unit => isUnitOrBaseUnitSelected(unit, this.supplierUnitSelect$));

    $('tr select[name$="[unit]"]', this.unitRatiosTable$).each((_, unitSelect) => {
      $('option[value!=""]' + remainingAvailableUnits.map(unit => `[value!="${unit.key}"]`).join(''), unitSelect).remove();
      const missingUnits = remainingAvailableUnits.filter(unit => $(`option[value="${unit.key}"]`, unitSelect).length === 0);
      for (const missingUnit of missingUnits) {
        $(unitSelect).append($(`<option value="${missingUnit.key}">${missingUnit.label}</option>`));
      }
      remainingAvailableUnits = remainingAvailableUnits.filter(unit => isUnitOrBaseUnitSelected(unit, $(unitSelect)));
    });

    this.updateAvailableBillingAndGroupOrderUnits();
  }

  findAboveUnit(row$) {
    const previousRow$ = row$.prev();
    if (previousRow$.length > 0) {
      const unitKey = previousRow$.find('select[name$="[unit]"]').val();
      const unit = this.availableUnits.find(availableUnit => availableUnit.key === unitKey);
      if (!unit) {
        return '?';
      }
      return unit.label;
    } else {
      const unitKey = this.supplierUnitSelect$.val();
      if (unitKey !== '') {
        const unit = this.availableUnits.find(availableUnit => availableUnit.key === unitKey);
        if (!unit) {
          return '?';
        }
        return unit.label;
      } else {
        const unitVal = this.unit$.val();
        return unitVal ? unitVal : '?';
      }
    }
  }

  updateAvailableBillingAndGroupOrderUnits() {
    const unitsSelectedAbove = [];
    if (this.supplierUnitSelect$.val() != '') {
      const chosenOption$ = $(`option[value="${this.supplierUnitSelect$.val()}"]`, this.supplierUnitSelect$);
      unitsSelectedAbove.push({ key: chosenOption$.val(), label: chosenOption$.text() });
    } else {
      const unitVal = this.unit$.val();
      unitsSelectedAbove.push({ key: '', label: unitVal ? unitVal : '?' });
    }

    const selectedRatioUnits = $('tr select[name$="[unit]"]', this.unitRatiosTable$).map((_, ratioSelect) => ({
      key: $(ratioSelect).val(),
      label: $(`option[value="${$(ratioSelect).val()}"]`, ratioSelect).text()
    }))
      .get()
      .filter(option => option.key !== '');

    unitsSelectedAbove.push(...selectedRatioUnits);

    const availableUnits = [];
    for (const unitSelectedAbove of unitsSelectedAbove) {
      availableUnits.push(unitSelectedAbove, ...this.availableUnits.filter(availableUnit => {
        if (availableUnit.key === unitSelectedAbove.key) {
          return false;
        }

        const otherUnit = this.availableUnits.find(unit => unit.key === unitSelectedAbove.key);
        return otherUnit !== undefined && otherUnit.baseUnit !== null && availableUnit.baseUnit === otherUnit.baseUnit;
      }));
    }

    this.updateUnitsInSelect(availableUnits, this.billingUnit$);
    this.billingUnit$.parents('.fold-line').css('display', availableUnits.length > 1 ? 'block' : 'none');
    this.updateUnitsInSelect(availableUnits, this.groupOrderUnit$);
    this.updateUnitsInSelect(availableUnits, this.priceUnit$);
  }

  updateUnitsInSelect(units, unitSelect$) {
    const valueBeforeUpdate = unitSelect$.val();

    unitSelect$.empty();
    for (const unit of units) {
      unitSelect$.append($(`<option value="${unit.key}">${unit.label}</option>`));
    }

    const initialValue = unitSelect$.attr('data-initial-value');
    if (initialValue) {
      unitSelect$.val(initialValue);
      unitSelect$.removeAttr('data-initial-value');
    } else {
      if (unitSelect$.find(`option[value="${valueBeforeUpdate}"]`).length > 0) {
        unitSelect$.val(valueBeforeUpdate);
      } else {
        unitSelect$.val(unitSelect$.find('option:first').val());
      }
    }

    unitSelect$.trigger('change');

    unitSelect$.parents('.control-group').find('.immutable_unit_label').remove();
    if (units.length === 1) {
      unitSelect$.hide();
      unitSelect$.parents('.control-group').append($(`<div class="immutable_unit_label control-label">${units[0].label}</div>`))
    } else {
      unitSelect$.show();
    }
  }

  setFieldVisibility() {
    const firstUnitRatioQuantity$ = $('tr input[name$="[quantity]"]:first', this.unitRatiosTable$);
    const firstUnitRatioUnit$ = $('tr select[name$="[unit]"]:first', this.unitRatiosTable$);

    const supplierOrderUnitSet = !!this.unit$.val() || !!this.supplierUnitSelect$.val();
    const unitRatiosVisible = supplierOrderUnitSet || this.unitRatiosTable$.find('tbody tr').length > 0;
    this.unitRatiosTable$.parents('.fold-line').toggle(unitRatiosVisible);

    if (!unitRatiosVisible) {
      $('tbody tr', this.unitRatiosTable$).remove();
    }

    mergeJQueryObjects([
      this.unit$,
      this.supplierUnitSelect$,
      firstUnitRatioQuantity$,
      firstUnitRatioUnit$
    ]).off('change.article_form_visibility')
      .on('change.article_form_visibility', () =>
        this.setFieldVisibility()
      );

    firstUnitRatioQuantity$
      .off('keyup.article_form_visibility')
      .on('keyup.article_form_visibility', () => firstUnitRatioQuantity$.trigger('change'));
  }

  prepareRatioDataForSequentialRepresentation() {
    const indices = $(`input[name^="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes]"][name$="[quantity]"]`)
      .toArray()
      .map((field) => parseInt(field.name.replace(/.+\[([0-9]+)\]\[quantity\]/, '$1')));
    const maxIndex = Math.max(...indices);
    const minIndex = Math.min(...indices);

    for (let i = maxIndex; i > minIndex; i--) {
      const currentField$ = $(`input[name="${this.ratioQuantityFieldNameByIndex(i)}"]`, this.articleForm$);
      const currentValue = currentField$.val();
      const previousValue = $(`input[name="${this.ratioQuantityFieldNameByIndex(i - 1)}"]:last`, this.articleForm$).val();
      currentField$.val(round(currentValue / previousValue));
    }
  }

  convertPriceToPriceUnit() {
    const supplierUnitPrice = this.price$.val();
    const priceUnit = this.priceUnit$.val();
    if (priceUnit === undefined) {
      return;
    }
    const ratio = this.getUnitRatio(1, priceUnit, this.supplierUnitSelect$.val());
    const relativePrice = round(supplierUnitPrice * ratio);
    this.price$.val(relativePrice);
  }

  initializeOrderedAndReceivedUnits() {
    this.billingUnit$.change(() => {
      this.updateOrderedAndReceivedUnits();
      this.initializeOrderedAndReceivedUnitsConverters();
    });
    this.billingUnit$.trigger('change');
  }

  updateOrderedAndReceivedUnits() {
    const billingUnitKey = this.billingUnit$.val();
    const billingUnitLabel = this.getUnitLabel(billingUnitKey);
    const inputs$ = mergeJQueryObjects([this.unitsToOrder$, this.unitsReceived$]);
    inputs$.parent().find('.unit_label').remove();
    if (billingUnitLabel.trim() !== '') {
      inputs$.after($(`<span class="unit_label ml-1">${this.getUnitsConverter().isUnitSiConversible(billingUnitKey) ? '' : 'x '}${billingUnitLabel}</span>`));
    }
    if (this.previousBillingUnit !== undefined) {
      this.convertOrderedAndReceivedUnits(this.previousBillingUnit, billingUnitKey);
    }
    this.previousBillingUnit = billingUnitKey;
  }

  convertOrderedAndReceivedUnits(fromUnit, toUnit) {
    const inputs$ = mergeJQueryObjects([this.unitsToOrder$, this.unitsReceived$]);
    inputs$.each((_, input) => {
      const input$ = $(input);
      const val = input$.val();

      if (val !== '') {
        try {
          const convertedValue = this.getUnitRatio(val, fromUnit, toUnit);
          input$.val(round(convertedValue));
        } catch (e) {
          // In some cases it's impossible to perform this conversion - just leave the original value
        }
      }
    });
  }

  initializeOrderedAndReceivedUnitsConverters() {
    this.unitsToOrder$.unitConversionField('destroy');
    this.unitsReceived$.unitConversionField('destroy');

    const opts = {
      units: this.units,
      popoverTemplate$: this.unitConversionPopoverTemplate$,
      ratios: this.ratios,
      supplierOrderUnit: this.supplierUnitSelect$.val(),
      customUnit: this.unit$.val(),
      defaultUnit: this.billingUnit$.val()
    };
    this.unitsToOrder$.unitConversionField(opts);
    this.unitsReceived$.unitConversionField(opts);
  }

  loadRatios() {
    this.ratios = [];
    this.unitRatiosTable$.find('tbody tr').each((_, element) => {
      const tr$ = $(element);
      const unit = tr$.find(`select[name^="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes]"][name$="[unit]"]`).val();
      const quantity = tr$.find(`input[name^="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes]"][name$="[quantity]"]:last`).val();
      this.ratios.push({ unit, quantity });
    });
  }

  undoSequentialRatioDataRepresentation() {
    let previousValue;
    $(`input[name^="${this.unitFieldsNamePrefix}[article_unit_ratios_attributes]"][name$="[quantity]"]`).each((_, field) => {
      let currentField$ = $(field);
      let quantity = currentField$.val();

      if (previousValue !== undefined) {
        const td$ = currentField$.closest('td');
        const name = currentField$.attr('name');
        const ratioNameRegex = new RegExp(`${escapeForRegex(this.unitFieldsNamePrefix)}\\[article_unit_ratios_attributes\\]\\[([0-9]+)\\]`);
        const index = name.match(ratioNameRegex)[1];
        quantity = quantity * previousValue;
        currentField$ = $(`<input type="hidden" name="${this.ratioQuantityFieldNameByIndex(index)}" value="${quantity}" />`);
        td$.append(currentField$);
      }

      previousValue = quantity;
    });
  }

  ratioQuantityFieldNameByIndex(i) {
    return `${this.unitFieldsNamePrefix}[article_unit_ratios_attributes][${i}][quantity]`;
  }

  enableSubmitButton() {
    this.submitButton$.removeAttr('disabled');
  }
}


// TODO: Move those functions to some global js utils file (see https://github.com/foodcoopsat/foodsoft_hackathon/issues/88):
function mergeJQueryObjects(array_of_jquery_objects) {
  return $($.map(array_of_jquery_objects, function (el) {
    return el.get();
  }));
}

function round(num, precision) {
  if (precision === undefined) {
    precision = 3;
  }
  const factor = Math.pow(10, precision);
  return Math.round((num + Number.EPSILON) * factor) / factor;
}

function escapeForRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
