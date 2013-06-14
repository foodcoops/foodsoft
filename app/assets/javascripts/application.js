//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery.tokeninput
//= require bootstrap-datepicker
//= require bootstrap-datepicker.de
//= require jquery.observe_field
//= require rails.validations
//= require_self
//= require ordering

// function for sorting DOM elements
$.fn.sorter = (function(){
  // Thanks to James Padolsey and Avi Deitcher
  // http://james.padolsey.com/javascript/sorting-elements-with-jquery/#comment-29400
  var sort = [].sort;
  
  return function(comparator, getSortable) {
    getSortable = getSortable || function(){return this;};
    
    var sorted = sort.call(this, comparator); // sort all elements in memory
    var prevElmt = null;
    for(i=sorted.length-1; i>=0; --i) { // loop starting from last
      var criterionElmt = sorted[i];
      var curElmt = ( 'function' === typeof getSortable ) ? ( getSortable.call(criterionElmt) ) : ( criterionElmt );
      var parent = curElmt.parentNode;
      if (!prevElmt) {
        parent.appendChild(curElmt); // place last element to the end
      } else {
        parent.insertBefore(curElmt, prevElmt); // move each element before the previous one
      }
      prevElmt = curElmt;
    }
    return sorted;
  
  };

})();

// allow touch devices to work on click events
//   http://stackoverflow.com/a/16221066
$.fn.extend({ _on: (function(){ return $.fn.on; })() });
$.fn.extend({
    on: (function(){
        var isTouchSupported = 'ontouchstart' in window || window.DocumentTouch && document instanceof DocumentTouch;
        return function( types, selector, data, fn, one ) {
            if (typeof types == 'string' && isTouchSupported && !(types.match(/touch/gi))) types = types.replace(/click/gi, 'touchstart');
            return this._on( types, selector, data, fn);
        };
    }()),
});

// Load following statements, when DOM is ready
$(function() {

    // Show/Hide a specific DOM element
    $('a[data-toggle-this]').live('click', function() {
        $($(this).data('toggle-this')).toggle();
        return false;
    });

    // Remove this item from DOM
    $('a[data-remove-this]').live('click', function() {
        $($(this).data('remove-this')).remove();
        return false;
    });

    // Check/Uncheck a single checkbox
    $('[data-check-this]').live('click', function() {
        var checkbox = $($(this).data('check-this'));
        checkbox.attr('checked', !checkbox.is(':checked'));
        highlightRow(checkbox);
        return false;
    });

    // Check/Uncheck all checkboxes for a specific form
    $('input[data-check-all]').live('click', function() {
        var status = $(this).is(':checked');
        var context = $(this).data('check-all');
        var elms = $('input[type="checkbox"]', context);
        for(i=elms.length-1; i>=0; --i) { // performance can be an issue here, so use native loop
          var elm = elms[i];
          elm.checked = status;
          highlightRow($(elm));
        }
    });

    // Submit form when changing a select menu.
    $('form[data-submit-onchange] select').live('change', function() {
        var confirmMessage = $(this).children(':selected').data('confirm');
        if (confirmMessage) {
            if (confirm(confirmMessage)) {
                $(this).parents('form').submit();
            }
        } else {
            $(this).parents('form').submit();
        }
        return false;
    });

    // Submit form when changing text of an input field
    // Use jquery observe_field plugin
    $('form[data-submit-onchange] input[type=text]').each(function() {
        $(this).observe_field(1, function() {
            $(this).parents('form').submit();
        });
    });

    // Submit form when clicking on checkbox
    $('form[data-submit-onchange] input[type=checkbox]:not(input[data-ignore-onchange])').click(function() {
        $(this).parents('form').submit();
    });

    $('[data-redirect-to]').bind('change', function() {
        var newLocation = $(this).children(':selected').val();
        if (newLocation != "") {
            document.location.href = newLocation;
        }
    });

    // Remote paginations
    $('div.pagination[data-remote] a').live('click', function() {
        $.getScript($(this).attr('href'));
        return false;
    });

    // Show and hide loader on ajax callbacks
    $('*[data-remote]').bind('ajax:beforeSend', function() {
        $('#loader').show();
    });

    $('*[data-remote]').bind('ajax:complete', function() {
        $('#loader').hide();
    });

    // Disable submit button on ajax forms
    $('form[data-remote]').bind('ajax:beforeSend', function() {
        $(this).children('input[type="submit"]').attr('disabled', 'disabled');
    });

    // Use bootstrap datepicker for dateinput
    $('.datepicker').datepicker({format: 'yyyy-mm-dd', weekStart: 1, language: 'de'});
    
    // Init table sorting
    var myBars = $('span.sorter-bar');
    myBars.html('<button type="button" class="sorter-button btn btn-mini"><i class="icon-chevron-up"></i></button><button type="button" class="sorter-button btn btn-mini"><i class="icon-chevron-down"></i></button>');
    $('button:nth-child(1)', myBars).click(function(e) {sortTable(e, false);}).attr('title', 'Sortiere aufsteigend');
    $('button:nth-child(2)', myBars).click(function(e) {sortTable(e, true);}).attr('title', 'Sortiere absteigend (umgekehrt)');
  
    $('span.sorter-bar.default-sort-asc button:nth-child(1)').trigger('click');
    $('span.sorter-bar.default-sort-desc button:nth-child(2)').trigger('click');
});

// parse a string to a float
function myFloatParse(input) {
  var number = input.trim();
  number = number.split(' ')[0];
  number = number.replace(',', '.');
  number = parseFloat(number, 10);
  return number;
}

// compare two elements interpreted as text
function compareText(a, b) {
  return $.trim(a.textContent).toLowerCase() < $.trim(b.textContent).toLowerCase() ? -1 : 1;
}

// compare two elements interpreted as float
function compareFloat(a, b) {
  a = myFloatParse( $(a).text() );
  b = myFloatParse( $(b).text() );
  return ( a<b ) ? ( -1 ) : ( 1 );
}

// wrapper for $.fn.sorter (see above) for sorting tables
function sortTable(e, inverted) {
  var sign = ( inverted ) ? ( -1 ) : ( 1 );
  
  var myBar = $(e.currentTarget).closest('.sorter-bar'); // bar containing the clicked up/down arrow
  var sortCriterion = myBar.data('sortCriterion'); // class name of (usually td) elements which define the order
  var compareFunction = myBar.data('compareFunction'); // function to compare two element contents for ordering
  var sortElement = myBar.data('sortElement'); // name of function which returns the movable element (default: 'thisParent')
  var myTable = myBar.closest('table'); // table to sort
  
  sortElement = ( 'undefined' === typeof sortElement ) ? ( function() {return this.parentNode;} ) : ( window[sortElement] ); // is this dirty?
  
  $('.' + sortCriterion, myTable).sorter(
    function(a, b) {
      return sign*window[compareFunction](a, b); // again dirty?
    },
    sortElement
  );
  
  $('.sorter-button', myTable).removeClass('btn-primary active');
  $(e.currentTarget).addClass('btn-primary active');
}

// resort a certain table (e.g. after DOM update)
function updateSort(whichTable) {
  $('.sorter-bar button.active.btn-primary', whichTable).trigger('click');
}

// gives the row an yellow background
function highlightRow(checkbox) {
  var row = checkbox.closest('tr');
  if (checkbox.is(':checked')) {
    row.addClass('selected');
  } else {
    row.removeClass('selected');
  }
}

// Use with auto_complete to set a unique id,
// e.g. when the user selects a (may not unique) name
// There must be a hidden field with the id 'hidden_field'
function setHiddenId(text, li) {
  $('hidden_id').value = li.id;
}
