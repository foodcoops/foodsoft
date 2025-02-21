class UnitsConverter {
  constructor(units, ratios, supplierOrderUnit) {
    this.units = units;
    this.ratios = ratios;
    this.supplierOrderUnit = supplierOrderUnit;
  }

  getUnitQuantity(unitId) {
    if (unitId === this.supplierOrderUnit) {
      return 1;
    }

    const ratio = this.ratios.find(ratio => ratio.unit === unitId);
    if (ratio !== undefined) {
      return ratio.quantity;
    }

    const unit = this.units[unitId];
    const relatedRatio = this.ratios.find(ratio => this.units[ratio.unit].baseUnit === unit.baseUnit);
    if (relatedRatio !== undefined) {
      const relatedUnit = this.units[relatedRatio.unit];
      return Big(relatedRatio.quantity).div(unit.conversionFactor).mul(relatedUnit.conversionFactor).toNumber();
    }

    const supplierOrderUnitConversionFactor = this.units[this.supplierOrderUnit].conversionFactor;
    return Big(supplierOrderUnitConversionFactor).div(unit.conversionFactor).toNumber();
  }

  getUnitRatio(quantity, inputUnit, outputUnit) {
    return Big(quantity).div(this.getUnitQuantity(inputUnit)).mul(this.getUnitQuantity(outputUnit)).toNumber();
  }

  isUnitSiConversible(unitId) {
    const unit = this.units[unitId];
    if (unit === undefined) {
      return false;
    }
    return !!unit.conversionFactor;
  }
}
