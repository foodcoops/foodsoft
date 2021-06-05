// JavaScript that handles the dynamic ordering quantities on the ordering page.
//
// In a JavaScript block on the actual view, define the article data by calls to setData().
// You should also set the available group balance through setGroupBalance(amount).
//
// Call setDecimalSeparator(char) to overwrite the default character "." with a localized value.

var modified = false;           // indicates if anything has been clicked on this page
var groupBalance = 0;           // available group money
var minimumBalance = 0;         // minimum group balance for the order to be succesful
var toleranceIsCostly = true;   // default tolerance behaviour
var isStockit = false;          // Whether the order is from stock oder normal supplier

// Article data arrays:
var price = new Array();
var unit = new Array();              // items per order unit
var itemTotal = new Array();         // total item price
var quantityOthers = new Array();
var toleranceOthers = new Array();
var itemsAllocated = new Array();    // how many items the group has been allocated and should definitely get
var quantityAvailable = new Array(); // stock_order. how many items are currently in stock

function setToleranceBehaviour(value) {
    toleranceIsCostly = value;
}

function setStockit(value) {
    isStockit = value;
}

function setGroupBalance(amount) {
    groupBalance = amount;
}

function setMinimumBalance(amount) {
    minimumBalance = amount;
}

function addData(orderArticleId, itemPrice, itemUnit, itemSubtotal, itemQuantityOthers, itemToleranceOthers, allocated, available) {
    var i = orderArticleId;
    price[i] = itemPrice;
    unit[i] = itemUnit;
    itemTotal[i] = itemSubtotal;
    quantityOthers[i] = itemQuantityOthers;
    toleranceOthers[i] = itemToleranceOthers;
    itemsAllocated[i] = allocated;
    quantityAvailable[i] = available;
}

function increaseQuantity(item) {
    var $el   = $('#q_' + item),
        value = Number($el.val()) + 1,
        max   = $el.data('max');
    if (value > max) { value = max; }
    if (!isStockit || (value <= (quantityAvailable[item] + itemsAllocated[item]))) {
        update(item, value, $('#t_' + item).val());
    }
}

function decreaseQuantity(item) {
    var $el   = $('#q_' + item),
        value = Number($el.val()) - 1,
        min   = $el.data('min') || 0;
    if (value >= min) {
        update(item, value, $('#t_' + item).val());
    }
}

function increaseTolerance(item) {
    var $el   = $('#t_' + item),
        value = Number($el.val()) + 1;
        max   = $el.data('max');
    if (value > max) { value = max; }
    update(item, $('#q_' + item).val(), value);
}

function decreaseTolerance(item) {
    var $el   = $('#t_' + item),
        value = Number($el.val()) - 1,
        min   = $el.data('min') || 0;
    if (value >= min) {
        update(item, $('#q_' + item).val(), value);
    }
}

function update(item, quantity, tolerance) {
    // set modification flag
    modified = true

    // update hidden input fields
    $('#q_' + item).val(quantity);
    $('#t_' + item).val(tolerance);

    // calculate how many units would be ordered in total
    var units = calcUnits(unit[item], quantityOthers[item] + Number(quantity), toleranceOthers[item] + Number(tolerance));
    if (unitCompletedFromTolerance(unit[item], quantityOthers[item] + Number(quantity), toleranceOthers[item] + Number(tolerance))) {
        $('#units_' + item).html('<span style=\"color:grey\">' + String(units) + '</span>');
    } else {
        $('#units_' + item).html(String(units));
    }

    // update used/unused quantity
    var available = Math.max(0, units * unit[item] - quantityOthers[item]);
    var q_used = Math.min(available, quantity);
    // ensure that at least the amout of items this group has already been allocated is used
    if (quantity >= itemsAllocated[item] && q_used < itemsAllocated[item]) {
        q_used = itemsAllocated[item];
    }
    $('#q_used_' + item).html(String(q_used));
    $('#q_unused_' + item).html(String(quantity - q_used));
    $('#q_total_' + item).html(String(Number(quantity) + quantityOthers[item]));

    // update used/unused tolerance
    if (unit[item] > 1) {
        available = Math.max(0, available - q_used - toleranceOthers[item]);
        t_used = Math.min(available, tolerance);
        $('#t_used_' + item).html(String(t_used));
        $('#t_unused_' + item).html(String(tolerance - t_used));
        $('#t_total_' + item).html(String(Number(tolerance) + toleranceOthers[item]));
    }

    // update total price
    if(toleranceIsCostly == true) {
        itemTotal[item] = price[item] * (Number(quantity) + Number(tolerance));
    } else {
        itemTotal[item] = price[item] * (Number(quantity));
    }
    $('#price_' + item + '_display').html(I18n.l("currency", itemTotal[item]));

    // update missing units
    var missing_units = calcMissingItems(unit[item], quantityOthers[item] + Number(quantity), toleranceOthers[item] + Number(tolerance)),
        missing_units_css = '';

    if (missing_units <= 0 || missing_units == unit[item]) {
        missing_units = 0;
        if (quantity > 0) {
            missing_units_css = 'missing-none';
        } else {
            missing_units_css = '';
        }
    } else if (missing_units == 1) {
        missing_units_css = 'missing-few';
    } else {
        missing_units_css = 'missing-many';
    }
    $('#missing_units_' + item)
        .html(String(missing_units))
        .closest('tr')
        .removeClass('missing-many missing-few missing-none')
        .addClass(missing_units_css);

    updateBalance();
    updateButtons($('#q_'+item).closest('tr'));
}

function calcUnits(unitSize, quantity, tolerance) {
    var units = Math.floor(quantity / unitSize)
    var remainder = quantity % unitSize
    return units + ((remainder > 0) && (remainder + tolerance >= unitSize) ? 1 : 0)
}

function calcMissingItems(unitSize, quantity, tolerance) {
    var remainder = quantity % unitSize
    return remainder > 0 && remainder + tolerance < unitSize ? unitSize - remainder - tolerance : 0
}

function unitCompletedFromTolerance(unitSize, quantity, tolerance) {
    var remainder = quantity % unitSize
    return (remainder > 0 && (remainder + tolerance >= unitSize));
}

function updateBalance() {
    // update total price and order balance
    var total = 0;
    for (i in itemTotal) {
        total += itemTotal[i];
    }
    $('#total_price').html(I18n.l("currency", total));
    var balance = groupBalance - total;
    $('#new_balance').html(I18n.l("currency", balance));
    $('#total_balance').val(I18n.l("currency", balance));
    // determine bgcolor and submit button state according to balance
    var bgcolor = '';
    if (balance < minimumBalance) {
        bgcolor = '#FF0000';
        $('#submit_button').attr('disabled', 'disabled')
    } else {
        $('#submit_button').removeAttr('disabled')
    }
    // update bgcolor
    for (i in itemTotal) {
        $('#td_price_' + i).css('background-color', bgcolor);
    }
}

function updateButtons($el) {
    // enable/disable buttons depending on min/max vs. value
    $el.find('a[data-increase_quantity]').each(function() {
      var $q = $el.find('#q_'+$(this).data('increase_quantity'));
      $(this).toggleClass('disabled', $q.val() >= $q.data('max'));
    });
    $el.find('a[data-decrease_quantity]').each(function() {
      var $q = $el.find('#q_'+$(this).data('decrease_quantity'));
      $(this).toggleClass('disabled', $q.val() <= ($q.data('min')||0));
    });
    $el.find('a[data-increase_tolerance]').each(function() {
      var $t = $el.find('#t_'+$(this).data('increase_tolerance'));
      $(this).toggleClass('disabled', $t.val() >= $t.data('max'));
    });
    $el.find('a[data-decrease_tolerance]').each(function() {
      var $t = $el.find('#t_'+$(this).data('decrease_tolerance'));
      $(this).toggleClass('disabled', $t.val() <= ($t.data('min')||0));
    });
}

$(function() {
    $('a[data-increase_quantity]').on('touchclick', function() {
        increaseQuantity($(this).data('increase_quantity'));
    });
    $('a[data-decrease_quantity]').on('touchclick', function() {
        decreaseQuantity($(this).data('decrease_quantity'));
    });
    $('a[data-increase_tolerance]').on('touchclick', function() {
        increaseTolerance($(this).data('increase_tolerance'));
    });
    $('a[data-decrease_tolerance]').on('touchclick', function() {
        decreaseTolerance($(this).data('decrease_tolerance'));
    });

    $('a[data-confirm_switch_order]').on('touchclick', function() {
        return (!modified || confirm(I18n.t('js.ordering.confirm_change')));
    });

    updateButtons($(document));
});
