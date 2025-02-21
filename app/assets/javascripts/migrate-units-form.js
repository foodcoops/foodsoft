class MigrateUnitsForm {
  constructor(articleUnitRatioTemplate$, table$, units) {
    this.articleUnitRatioTemplate$ = articleUnitRatioTemplate$;
    this.table$ = table$;
    this.units = units;

    this.initializeUnitSelects();
    this.initializeArticlesList();
  }

  loadAvailableUnits() {
    this.availableUnits = Object.entries(this.units)
      .filter(([, unit]) => unit.visible)
      .map(([code, unit]) => ({ key: code, label: unit.name, baseUnit: unit.baseUnit, symbol: unit.symbol, aliases: unit.aliases ? unit.aliases : [] }));
  }

  initializeUnitSelects() {
    this.loadAvailableUnits();
    this.table$.find('select[name^="samples["]').select2();
    const form = this;
    this.table$.find('select[name^="samples["][name$="[supplier_order_unit]"]').each(function() {
      form.updateUnitsInSelect(form.availableUnits, $(this));
      form.updateFirstUnitRatioSelect($(this).parents('tr'));
      form.updateGroupOrderUnitSelect($(this).parents('tr'));
      form.updateFirstUnitRatioQuantity($(this).parents('tr'));
    });
    this.table$.find('select[name^="samples["][name$="[supplier_order_unit]"]').change(function() {
      form.updateFirstUnitRatioSelect($(this).parents('tr'));
      form.updateGroupOrderUnitSelect($(this).parents('tr'));
      form.updateFirstUnitRatioQuantity($(this).parents('tr'));
    });
    this.table$.find('select[name^="samples["][name$="[first_ratio_unit]"]').change(function() {
      form.updateGroupOrderUnitSelect($(this).parents('tr'));
      form.updateFirstUnitRatioQuantity($(this).parents('tr'));
    });
  }

  updateFirstUnitRatioQuantity(row$) {
    const firstRatioSelect$ = row$.find('select[name$="[first_ratio_unit]"]');
    const firstRatioQuantity$ = row$.find('input[name$="[first_ratio_quantity]"]');
    if (firstRatioSelect$.val() === '') {
      firstRatioQuantity$.val('');
      firstRatioQuantity$.attr('disabled', 'disabled');
    } else {
      firstRatioQuantity$.removeAttr('disabled');
    }
  }

  updateGroupOrderUnitSelect(row$) {
    const supplierUnitSelect$ = row$.find('select[name$="[supplier_order_unit]"]');
    const firstRatioSelect$ = row$.find('select[name$="[first_ratio_unit]"]');
    const groupOrderUnit$ = row$.find('select[name$="[group_order_unit]"]');

    const unitsSelectedAbove = [];
    const chosenSupplierUnitOption$ = supplierUnitSelect$.find(`option[value="${supplierUnitSelect$.val()}"]`);
    unitsSelectedAbove.push({ key: chosenSupplierUnitOption$.val(), label: chosenSupplierUnitOption$.text() });

    if (firstRatioSelect$.val() != '') {
      const chosenFirstRatioOption$ = firstRatioSelect$.find(`option[value="${firstRatioSelect$.val()}"]`);
      unitsSelectedAbove.push({ key: chosenFirstRatioOption$.val(), label: chosenFirstRatioOption$.text() });
    }

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

    this.updateUnitsInSelect(availableUnits, groupOrderUnit$);
  }

  updateFirstUnitRatioSelect(row$) {
    const supplierUnitSelect$ = row$.find('select[name$="[supplier_order_unit]"]');
    const firstRatioSelect$ = row$.find('select[name$="[first_ratio_unit]"]');
    const isUnitOrBaseUnitSelected = (unit, select$) => {
      const code = select$.val();
      const selectedUnit = this.units[code];
      return unit.key !== code && (!unit.baseUnit || !selectedUnit || !selectedUnit.baseUnit || unit.baseUnit !== selectedUnit.baseUnit);
    };

    const remainingAvailableUnits = this.availableUnits.filter(unit => isUnitOrBaseUnitSelected(unit, supplierUnitSelect$));
    this.updateUnitsInSelect(remainingAvailableUnits, firstRatioSelect$, true);
  }

  initializeArticlesList() {
    this.table$.find('.articles-list .expander').click(function () {
      const currentList$ = $(this).parents('.articles-list');
      currentList$.find('.expander').addClass('d-none');
      currentList$.find('.collapser').removeClass('d-none');
      currentList$.find('.list').removeClass('d-none');
    });

    this.table$.find('.articles-list .collapser').click(function () {
      const currentList$ = $(this).parents('.articles-list');
      currentList$.find('.expander').removeClass('d-none');
      currentList$.find('.collapser').addClass('d-none');
      currentList$.find('.list').addClass('d-none');
    });
  }

  updateUnitsInSelect(units, unitSelect$, includeBlank) {
    const valueBeforeUpdate = unitSelect$.val();

    unitSelect$.empty();
    if (includeBlank) {
      unitSelect$.append($(`<option value=""></option>`));
    }
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
      unitSelect$.parents('.controls').hide();
      unitSelect$.parents('.control-group').append($(`<div class="immutable_unit_label control-label">${units[0].label}</div>`))
    } else {
      unitSelect$.parents('.controls').show();
    }
  }


}
