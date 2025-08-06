$(document).on('ready turbolinks:load', function () {
    $('.expand-trigger').click(function () {
        var tableRow = $(this).closest('tr')
        var orderId = tableRow.data('order_id');
        var multiOrderId = tableRow.data('multi_order_id');

        if(multiOrderId != undefined){
            var expandedRow = $('#expanded-multi-row-' + multiOrderId);
            console.log(multiOrderId);
        }
        else
        {
            var expandedRow = $('#expanded-row-' + orderId);
        }
        // Toggle visibility of the expanded row

        expandedRow.toggleClass('hidden');

        tableRow.toggleClass('border');
        expandedRow.toggleClass('bordered');

        return false; // Prevent the default behavior of the link
    });
});

$(document).on('click', '.merge-orders-btn', function () {
    const url = $(this).data('url');
    const selectedOrderIds = $('input[name="order_ids_for_multi_order[]"]:checked').map(function () {
        return $(this).val();
    }).get();

    $.ajax({
        url: url,
        method: 'POST',
        data: { order_ids_for_multi_order: selectedOrderIds },
        success: function (response) {
            window.location.reload();
        },
    });
});

$(document).off('change', '[class^="ajax-update-all-link-"] select').on('change', '[class^="ajax-update-all-link-"] select', function () {
    var selectedValue = $(this).val();
    var url = $(this).closest('a').attr('href');
    $.ajax({
        url: url,
        method: 'PATCH',
        data: { sepa_sequence_type: selectedValue },
        success: function (response) {
            // Handle success response
        },
        error: function (error) {
            console.log(error);
        }
    });
});

$(document).off('change', '.ajax-update-sepa-select').on('change', '.ajax-update-sepa-select', function () {
    var selectedValue = $(this).val();
    var url = $(this).data('url');
    console.log(url);
    console.log(selectedValue);
    $.ajax({
        url: url,
        method: 'PATCH',
        data: { sepa_sequence_type: selectedValue },
        success: function (response) {
            console.log("succeeded");
        },
        error: function (error) {
            console.error(error);
        }
    });
});
