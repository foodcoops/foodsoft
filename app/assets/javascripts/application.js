//= require jquery
//= require jquery_ujs
//= require select2
//= require twitter/bootstrap
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.de
//= require bootstrap-datepicker/locales/bootstrap-datepicker.nl
//= require bootstrap-datepicker/locales/bootstrap-datepicker.fr
//= require jquery.observe_field
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

// allow touch devices to work on click events
//   http://stackoverflow.com/a/16221066
$.fn.extend({ _on: (function(){ return $.fn.on; })() });
$.fn.extend({
    on: (function(){
        var isTouchSupported = 'ontouchstart' in window || window.DocumentTouch && document instanceof DocumentTouch;
        return function( types, selector, data, fn, one ) {
            if (typeof types == 'string' && isTouchSupported && !(types.match(/touch/gi))) types = types.replace(/click/gi, 'touchstart');
            return this._on( types, selector, data, fn, one );
        };
    }()),
});

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
    $(document).on('change', 'form[data-submit-onchange] select', function() {
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
    $(document).on('click', 'form[data-submit-onchange] input[type=checkbox]:not(input[data-ignore-onchange])', function() {
        $(this).parents('form').submit();
    });

    // The autocomplete attribute is used for both autocompletion and storing
    // for passwords, it's nice to store it when editing one's own profile,
    // but never autocomplete. When the data-autocomplete attribute is 'off',
    // any autocompleted values are removed again.
    // This is only implemented for passwords.
    $('input[type="password"][autocomplete="off"]').each(function() {
      // add dummy password field for autocompletion after losing username field focus
      $(this).before('<input type="password" name="_x_autocomplete_workaround" style="display:none"/>');
      // make sure we don't receive the remembered password by accident
      $(this).parentsUntil('form').on('submit', function(ev) {
        $('input[name="_x_autocomplete_workaround"]').val('');
      });
      // if the browser already filled it in here, clear the password
      $(this).val('');
    });

    $(document).on('change', '[data-redirect-to]', function() {
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

    // Show and hide loader on ajax callbacks
    //   and run newElementsReady() afterwards for new dom elements
    $(document).on('ajax:beforeSend', '[data-remote]', function(evt, xhr, settings) {
        $('#loader').show();
        // One idea was $(document).on('ajax:complete', '[data-remote'], ...)
        // but that doesn't work for a modal dialog that replaces itself.
        //   https://github.com/rails/jquery-ujs/issues/223
        if (!settings.complete)
          settings.complete = [];
        else if (!$.isArray(settings.complete))
          settings.complete = [settings.complete];
        settings.complete.push(function() {
            newElementsReady();
            $('#loader').hide();
        });
    });

    // Disable submit button on ajax forms
    $(document).on('ajax:beforeSend', 'form[data-remote]', function() {
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

    newElementsReady();
});

// classic document ready functions not supporting jQuery.on()
// so that we can catch dynamically created elements too
//   data-remote functions call this after successful ajax (see above),
//   other modifications need to call this function by themselves.
function newElementsReady() {
    // Use bootstrap datepicker for dateinput
    $('.datepicker').datepicker({format: 'yyyy-mm-dd', language: I18n.locale});

    // Use select2 for selects, except those with css class 'plain'
    $('select').not('.plain').select2({dropdownAutoWidth: true, width: 'off'});

    // Enable client side form validations - cannot be done too early
    //   this needs the 'focusin' event (instead of 'focus') because of
    //   bubbling - http://stackoverflow.com/questions/9577971
    $('form[data-validate]').one('focusin', function() {
      $(this).enableClientSideValidations();
    });
}

// select2 jQuery function with remote capabilities
//   Usage:
//    $('#autocomplete_input').select2_remote({
//       remote_url: '#{xyz_path(:format => json)}',
//       remote_init: #{form.object.xyz.map { |u| u.token_attributes }.to_json}
//       remote_pagesize: 100,
//     });
//   Only remote_url is required.
$.fn.extend({
  select2_remote: function(options) {

    var pagesize = options.remote_pagesize || 25;
    var _options = $.extend(true, {}, options, {
      ajax: {
        url: options.remote_url,
        data: function(term, page) {
          return {q: term, limit: pagesize, offset: (page-1)*pagesize};
        },
        results: function(data, page) {
          return { results: data.results, more: ((page-1)*pagesize)<data.total };
        },
      },
      initSelection: function (el, callback) {
        var values = options.remote_init;
        // if single select is given an array as init, that's fine
        if ($.isArray(values) && !options.multiple && !options.tags)
          values = values[0];
        callback(values);
      },
      // try to avoid linebreaking long values
      dropdownAutoWidth: true,
      // we set width in css
      width: 'off',
    });

    return $(this).select2(_options);
  }
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

