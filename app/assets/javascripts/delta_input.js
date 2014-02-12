
$(function() {
  $(document).on('click', 'button[data-increment]', function() {
    data_delta_update($('#'+$(this).data('increment')), +1);
  });
  $(document).on('click', 'button[data-decrement]', function() {
    data_delta_update($('#'+$(this).data('decrement')), -1);
  });
  $(document).on('change keyup', 'input[type="text"][data-delta]', function() {
    data_delta_update(this, 0);
  });
});

function data_delta_update(el, direction) {
  var id = $(el).attr('id');

  var min = $(el).data('min');
  var max = $(el).data('max');
  var delta = $(el).data('delta');
  var granularity = $(el).data('granularity');

  var val = $(el).val();
  var oldval = $.isNumeric(val) ? Number(val) : 0;
  var newval = oldval + delta*direction;

  if (newval < min) newval = min;
  if (newval > max) newval = max;

  // disable buttons when min/max reached
  $('button[data-decrement='+id+']').attr('disabled', newval<=min ? 'disabled' : null);
  $('button[data-increment='+id+']').attr('disabled', newval>=max ? 'disabled' : null);

  // warn when what was entered is not a number
  $(el).toggleClass('error', val!='' && val!='.' && (!$.isNumeric(val) || val < 0));

  // update field, unless the user is typing
  if (!$(el).is(':focus')) {
    $(el).val(round_float(newval, granularity));
    $(el).trigger('changed');
  }
}

// truncate numbers because of tiny floating point deviations
// if we don't do this, 1.0 might be shown as 0.99999999
function round_float(s, granularity) {
  var e = granularity ? 1/granularity : 1000;
  return Math.round(Number(s)*e) / e;
}

