


(function ( $ ) {

  class UnitConversionField {
    constructor(field$, units, popoverTemplate$, useTargetUnitForStep = true, ratios = undefined, supplierOrderUnit = undefined, defaultUnit = undefined, customUnit = undefined) {
      this.field$ = field$;
      this.popoverTemplate$ = popoverTemplate$;
      this.popoverTemplate = this.popoverTemplate$[0].content.querySelector('.popover_contents');
      this.units = units;
      this.useTargetUnitForStep = useTargetUnitForStep;
      this.ratios = ratios;
      this.supplierOrderUnit = supplierOrderUnit;
      this.defaultUnit = defaultUnit;
      this.customUnit = customUnit;

      this.loadArticleUnitRatios();
      this.unitSelectOptions = this.getUnitSelectOptions();

      this.converter = new UnitsConverter(this.units, this.ratios, this.supplierOrderUnit);

      // if there's less then two options, don't even bother showing the popover:
      this.disabled = this.unitSelectOptions.length < 2;

      this.opener$ = $('<button class="conversion-popover-opener btn btn-ordering"><i class="icon-retweet"></i></button>');
      this.opener$.attr('title', this.popoverTemplate.dataset.title);
      this.field$.after(this.opener$);
      if (this.field$.css('display') === 'none') {
        this.opener$.hide();
      }

      if (this.disabled) {
        this.opener$.attr('disabled', 'disabled');
        this.opener$.attr('title', this.popoverTemplate.dataset.disabledTitle);
        return;
      }

      this.initializeOpenListener();
    }

    loadArticleUnitRatios() {
      if (!this.ratios) {
        this.ratios = [];
        for (let i = 0; this.field$.data(`ratio-quantity-${i}`) !== undefined; i++) {
          this.ratios.push({
            quantity: parseFloat(this.field$.data(`ratio-quantity-${i}`)),
            unit: this.field$.data(`ratio-unit-${i}`),
          });
        }
      }

      if (this.supplierOrderUnit === undefined) {
        this.supplierOrderUnit = this.field$.data('supplier-order-unit');
      }
      if (this.customUnit === undefined) {
        this.customUnit = this.field$.data('custom-unit');
      }
      if (this.defaultUnit === undefined) {
        this.defaultUnit = this.field$.data('default-unit');
      }
    }

    initializeOpenListener() {
      this.field$.popover({title: this.popoverTemplate.dataset.title, placement: 'bottom', trigger: 'manual'});

      this.opener$.click((e) => {
        e.preventDefault();
        e.stopPropagation();
        this.openPopover()
      });

      this.field$.on('shown.bs.popover', () => this.initializeConversionPopover(this.field$.next('.popover')));
    }

    openPopover() {
      $(document).on('mousedown.unit-conversion-field', (e) => {
        if ($(e.target).parents('.popover').length !== 0 || e.target === this.field$[0]) {
          return;
        }

        this.closePopover();
      });
      this.field$.popover('show');
    }

    closePopover() {
      $(document).off('mousedown.unit-conversion-field');
      this.field$.off('change.unit-conversion-field');
      this.field$.popover('hide');
    }

    initializeConversionPopover(popover$) {
      let showAgainHack = false;
      if (!popover$.hasClass('wide')) {
        popover$.addClass('wide');
        showAgainHack = true;
      }

      const popoverContent$ = popover$.find('.popover-content');
      popoverContent$.empty();

      const contents$ = $(document.importNode(this.popoverTemplate, true));
      popoverContent$.append(contents$);

      if (showAgainHack) {
        this.openPopover();
        return;
      }

      this.quantityInput$ = contents$.find('input.quantity');
      this.quantityInput$.val(String(this.field$.val()).replace(',', '.'));
      this.quantityInput$
        .focus()
        .select();
      this.applyButton$ = contents$.find('input.apply');
      this.conversionResult$ = contents$.find('.conversion-result');
      this.unitSelect$ = contents$.find('select.unit');
      this.unitSelect$.append(this.unitSelectOptions.map(option => $(`<option value${option.value === undefined ? '' : `="${option.value}"`}>${option.label}</option>`)))
      let initialUnitSelectValue = this.defaultUnit;
      if (initialUnitSelectValue === undefined) {
        initialUnitSelectValue = this.unitSelectOptions[0].value;
      }
      this.unitSelect$.val(initialUnitSelectValue);

      this.previousUnitSelectValue = convertEmptyStringToUndefined(this.unitSelect$.val());

      this.unitSelect$.change(() => this.onUnitSelectChanged());

      // eslint-disable-next-line no-undef
      mergeJQueryObjects([this.quantityInput$, this.unitSelect$]).change(() => this.prepareConversion())
      this.quantityInput$.keyup(() => this.quantityInput$.trigger('change'));

      this.field$.on('change.unit-conversion-field', () => {
        this.quantityInput$.val(this.field$.val());
        this.quantityInput$.trigger('change')
        this.unitSelect$.val(initialUnitSelectValue);
      });

      contents$.find('input.cancel').click(() => this.closePopover());
      this.applyButton$.click(() => {
        this.applyConversion();
        this.closePopover();
      });

      this.onUnitSelectChanged();
      this.prepareConversion();
    }

    getUnitSelectOptions() {
      const options = [];
      const unit = this.units[this.supplierOrderUnit];
      options.push({
        value: this.supplierOrderUnit,
        label: unit === undefined ? this.customUnit : this.getUnitLabel(unit)
      });
      if (unit !== undefined) {
        options.push(...this.getRelatedUnits(this.supplierOrderUnit));
      }


      for (const ratio of this.ratios) {
        options.push({
          value: ratio.unit,
          label: this.getUnitLabel(this.units[ratio.unit])
        });

        options.push(...this.getRelatedUnits(ratio.unit));
      }

      return options.sort((a, b) => a.label.localeCompare(b.label));
    }

    getUnitLabel(unit) {
      let label = unit.name;
      if (unit.symbol != null) {
        label += ` (${unit.symbol})`;
      }

      return label;
    }

    prepareConversion() {
      const unit = this.defaultUnit === undefined ? this.supplierOrderUnit : this.defaultUnit;
      const unitLabel = this.unitSelectOptions.find(option => option.value === unit).label;
      this.conversionResult$.text('= ' + this.getConversionResult() + ' x ' + unitLabel);
      this.conversionResult$.parent().find('.numeric-step-error').remove();
      if (this.quantityInput$.is(':invalid')) {
        this.applyButton$.attr('disabled', 'disabled');
        const errorSpan$ = $(`<div class="numeric-step-error">${I18n.t('errors.step_error', {min: 0, granularity: this.quantityInput$.attr('step')})}</div>`);
        errorSpan$.show();
        this.conversionResult$.after(errorSpan$);
      } else {
        this.applyButton$.removeAttr('disabled');
      }
    }

    applyConversion() {
      this.field$
        .val(this.getConversionResult())
        .trigger('change');
    }

    getQuantityInputValue() {
      const val = parseFloat(this.quantityInput$.val().trim().replace(',', '.'));
      if (isNaN(val)) {
        return 0;
      }

      return val;
    }

    getTargetUnit() {
      return this.defaultUnit === undefined ? this.supplierOrderUnit : this.defaultUnit;
    }

    getConversionResult() {
      const result = this.converter.getUnitRatio(this.getQuantityInputValue(), convertEmptyStringToUndefined(this.unitSelect$.val()), this.getTargetUnit());
      return Big(result).round(4).toNumber();
    }

    onUnitSelectChanged() {
      const newValue = this.converter.getUnitRatio(this.getQuantityInputValue(), this.previousUnitSelectValue, convertEmptyStringToUndefined(this.unitSelect$.val()));
      this.quantityInput$.val(newValue);

      const selectedUnit = convertEmptyStringToUndefined(this.unitSelect$.val());
      this.previousUnitSelectValue = selectedUnit;

      const step = this.useTargetUnitForStep ? this.converter.getUnitRatio(this.field$.attr('step'), this.getTargetUnit(), selectedUnit) : 0.001;
      this.quantityInput$.attr('step', step);
    }

    getRelatedUnits(unitId) {
      return Object.entries(this.units)
        .filter(([id, unit]) => unit.visible && unit.baseUnit !== null && unit.baseUnit === this.units[unitId].baseUnit && id !== unitId)
        .map(([id, unit]) => ({
          value: id,
          label: this.getUnitLabel(unit)
        }));
    }
  }

  function convertEmptyStringToUndefined(str) {
    if (str === '') {
      return undefined;
    }

    return str;
  }

  const convertersMap = new Map();

  $.fn.unitConversionField = function (optionsOrAction) {
    const conversionField = convertersMap.get($(this)[0]);
    switch(optionsOrAction) {
      case 'getConversionField':
        return conversionField;
      case 'getConverter':
        return conversionField === undefined ? undefined : conversionField.converter;
      case 'destroy':
        if (conversionField === undefined || conversionField.field$ === undefined) {
          break;
        }
        conversionField.opener$.remove();
        convertersMap.delete($(this)[0]);
        break;
      default: {
        const converter = new UnitConversionField($(this), optionsOrAction.units, optionsOrAction.popoverTemplate$, optionsOrAction.useTargetUnitForStep, optionsOrAction.ratios, optionsOrAction.supplierOrderUnit, optionsOrAction.defaultUnit, optionsOrAction.customUnit);
        convertersMap.set($(this)[0], converter);
        break;
      }
    }

    return this;
  };


}( jQuery ));
