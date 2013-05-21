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
        var status = $(this).is(':checked')
        $($(this).data('check-all')).find('input[type="checkbox"]').each(function() {
            $(this).attr('checked', status);
            highlightRow($(this));
        });
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
});


// gives the row an yellow background
function highlightRow(checkbox) {
    var row = checkbox.parents('tr');
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