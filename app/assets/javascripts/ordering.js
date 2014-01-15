// JavaScript that handles the dynamic ordering quantities on the ordering page.
//
// In a JavaScript block on the actual view, define the article data by calls to setData().
// You should also set the available group balance through setGroupBalance(amount).
//
// Call setDecimalSeparator(char) to overwrite the default character "." with a localized value.

var modified = false    		// indicates if anything has been clicked on this page
var groupBalance = 0;			// available group money
var minimumBalance = 0;                 // minimum group balance for the order to be succesful
var toleranceIsCostly = true;   // default tolerance behaviour
var isStockit = false;          // Wheter the order is from stock oder normal supplier

// Article data arrays:
var price = new Array();
var unit = new Array();  		// items per order unit
var itemTotal = new Array();    // total item price
var quantityOthers = new Array();
var toleranceOthers = new Array();
var itemsAllocated = new Array();  // how many items the group has been allocated and should definitely get
var quantityAvailable = new Array();  // stock_order. how many items are currently in stock

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
    var value = Number($('#q_' + item).val()) + 1;
    if (!isStockit || (value <= (quantityAvailable[item] + itemsAllocated[item]))) {
        update(item, value, $('#t_' + item).val());
    }
}

function decreaseQuantity(item) {
    var value = Number($('#q_' + item).val()) - 1;
    if (value >= 0) {
        update(item, value, $('#t_' + item).val());
    }
}

function increaseTolerance(item) {
    var value = Number($('#t_' + item).val()) + 1;
    update(item, $('#q_' + item).val(), value);
}

function decreaseTolerance(item) {
    var value = Number($('#t_' + item).val()) - 1;
    if (value >= 0) {
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
    $('#q_grouptotal_' + item).html(String(Number(quantity)));
    $('#q_total_' + item).html(String(Number(quantity) + quantityOthers[item]));

    // update used/unused tolerance
    if (unit[item] > 1) {
        available = Math.max(0, available - q_used - toleranceOthers[item]);
        t_used = Math.min(available, tolerance);
        $('#t_used_' + item).html(String(t_used));
        $('#t_unused_' + item).html(String(tolerance - t_used));
        $('#t_grouptotal_' + item).html(String(Number(tolerance)));
        $('#t_total_' + item).html(String(Number(tolerance) + toleranceOthers[item]));
    }

    // update total price
    if(toleranceIsCostly == true) {
        itemTotal[item] = price[item] * (Number(quantity) + Number(tolerance));
    } else {
        itemTotal[item] = price[item] * (Number(quantity));
    }
    $('#price_' + item + '_display').html(I18n.l("currency", itemTotal[item]));

    // update unit counters
    var total_quantity = quantityOthers[item] + Number(quantity);
    var total_tolerance = toleranceOthers[item] + Number(tolerance);

    // same as OrderArticle#calculate_units_to_order
    var units_to_order = Math.floor(total_quantity/unit[item]);
    var remainder = total_quantity % unit[item];
    units_to_order += ((remainder > 0) && (remainder + total_tolerance >= unit[item]) ? 1 : 0)

    var progress_units = total_quantity+total_tolerance - units_to_order*unit[item];
    var progress_pct = Math.floor(Math.min(100, 100*progress_units/unit[item]));

    $('#unit_to_order_'+item).html(String(units_to_order*unit[item]));
    // progess bar update
    //   update decreasing number first, to make sure that together it's no more than 100%
    //   otherwise one of the numbers in the progress bar may temporarily disappear
    var bars = [
      [$('#progress_'+item+' .bar:nth-child(1)'), progress_pct,     progress_units],
      [$('#progress_'+item+' .bar:nth-child(2)'), 100-progress_pct, Math.max(0, unit[item]-progress_units)]
    ];
    if (Number(bars[0][0].html()) < progress_units) bars.reverse();
    $.each(bars, function(i, bar) {
      bar[0]
        .width(String(bar[1])+'%')
	.html(String(bar[2]));
    });

    // update balance
    updateBalance();
}

function calcUnits(unitSize, quantity, tolerance) {
    var units = Math.floor(quantity / unitSize)
    var remainder = quantity % unitSize
    return units + ((remainder > 0) && (remainder + tolerance >= unitSize) ? 1 : 0)
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
    $(document).triggerHandler({type: 'foodsoft:group_order_sum_changed'}, total, balance);
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

$(function() {
    $('input[data-increase_quantity]').click(function() {
        increaseQuantity($(this).data('increase_quantity'));
    });
    $('input[data-decrease_quantity]').click(function() {
        decreaseQuantity($(this).data('decrease_quantity'));
    });
    $('input[data-increase_tolerance]').click(function() {
        increaseTolerance($(this).data('increase_tolerance'));
    });
    $('input[data-decrease_tolerance]').click(function() {
        decreaseTolerance($(this).data('decrease_tolerance'));
    });

    $('a[data-confirm_switch_order]').click(function() {
        return (!modified || confirm(I18n.t('js.ordering.confirm_change')));
    });
});
