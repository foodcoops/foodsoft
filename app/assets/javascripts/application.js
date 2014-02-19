//= require jquery
//= require jquery_ujs
//= require select2
//= require twitter/bootstrap
//= require jquery.tokeninput
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.de
//= require bootstrap-datepicker/locales/bootstrap-datepicker.nl
//= require bootstrap-datepicker/locales/bootstrap-datepicker.fr
//= require list
//= require list.unlist
//= require list.delay
//= require list.reset
//= require rails.validations
//= require rails.validations.simple_form
//= require i18n
//= require i18n/translations
//= require_self
//= require ordering
//= require stupidtable
//= require touchclick
//= require delta_input

// Load following statements, when DOM is ready
$(function() {

    // Show/Hide a specific DOM element
    $(document).on('click', 'a[data-toggle-this]', function() {
        $($(this).data('toggle-this')).toggle();
        return false;
    });

    // Remove this item from DOM
    $(document).on('click', 'a[data-remove-this]', function() {
        $($(this).data('remove-this')).remove();
        return false;
    });

    // Check/Uncheck a single checkbox
    $(document).on('click', '[data-check-this]', function() {
        var checkbox = $($(this).data('check-this'));
        checkbox.attr('checked', !checkbox.is(':checked'));
        highlightRow(checkbox);
        return false;
    });

    // Check/Uncheck all checkboxes for a specific form
    $(document).on('click', 'input[data-check-all]', function() {
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
    $(document).on('change', 'form[data-submit-onchange] select:not([data-ignore-onchange])', function() {
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

    // Submit form when clicking on checkbox
    $(document).on('click', 'form[data-submit-onchange] input[type=checkbox]:not([data-ignore-onchange])', function() {
        $(this).parents('form').submit();
    });

    // Submit form when changing text of an input field.
    // Submission will be done after 500ms of not typed, unless data-submit-onchange=changed,
    // in which case it happens when the input box loses its focus ('changed' event).
    $(document).on('changed keyup focusin', 'form[data-submit-onchange] input[type=text]:not([data-ignore-onchange])', function(e) {
        var input = $(this);
        // when form has data-submit-onchange=changed, don't do updates while typing
        if (e.type!='changed' && input.parents('form[data-submit-onchange=changed]').length>0) {
          return true;
        }
        // remember old value when it's getting the focus
        if (e.type=='focusin') {
          input.data('old-value', input.val());
          return true;
        }
        // trigger timeout to submit form when value was changed
        clearTimeout(input.data('submit-timeout-id'));
        input.data('submit-timeout-id', setTimeout(function() {
          if (input.val() != input.data('old-value')) input.parents('form').submit();
          input.removeData('submit-timeout-id');
          input.removeData('old-value');
        }, 500));
    });

    $('[data-redirect-to]').bind('change', function() {
        var newLocation = $(this).children(':selected').val();
        if (newLocation != "") {
            document.location.href = newLocation;
        }
    });

    // Remote paginations
    $(document).on('click', 'div.pagination[data-remote] a', function() {
        $.getScript($(this).attr('href'));
        return false;
    });

    // Disable action of disabled buttons
    $(document).on('click', 'a.disabled', function() {
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

    // The autocomplete attribute is used for both autocompletion and storing
    // for passwords, it's nice to store it when editing one's own profile,
    // but never autocomplete. Only implemented for passwords.
    $('input[type="password"][autocomplete="off"][data-store="on"]').each(function() {
      $(this).on('change', function() {
        $(this).removeAttr('autocomplete');
      });
    });

    // Use bootstrap datepicker for dateinput
    $('.datepicker').datepicker({format: 'yyyy-mm-dd', language: I18n.locale});

    // bootstrap tooltips (for price)
    //   Extra options don't work when using selector, so override defaults
    //   https://github.com/twbs/bootstrap/issues/3875 . These can still be
    //   overridden per tooltip using data-placement attributes and the like.
    $.extend($.fn.tooltip.defaults, {
      html: true,
      animation: false,
      placement: 'left',
      container: 'body'
    });
    $(document).tooltip({
      selector: '[data-toggle~="tooltip"]',
    });
    
    // See stupidtable.js for initialization of local table sorting
});

// retrigger last local table sorting
function updateSort(table) {
  $('.sorting-asc, .sorting-desc', table).toggleClass('.sorting-asc .sorting-desc')
    .removeData('sort-dir').trigger('click'); // CAUTION: removing data field of plugin
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


