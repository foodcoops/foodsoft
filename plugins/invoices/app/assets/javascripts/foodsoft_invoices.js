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

function doTheDownload(selectedGroupOrderIds, orderId, url, supplier, mode = "all") {
    console.log(selectedGroupOrderIds);
    if (mode == "all") {
        var data = { order_id: orderId }
    }
    else {
        var data = { multi_group_order_ids: selectedGroupOrderIds }
    }
    if (mode == "all" || selectedGroupOrderIds.length > 0) {
        //suppress generic error warning
        $.ajaxSetup({
            global: false,
        });
        $.ajax({
            url: url,
            method: 'GET', // You may adjust the HTTP method as needed
            data: data,
            dataType: 'xml',
            success: function (response) {
                // Handle success response
                // Convert XML response to a Blob
                var blob = new Blob([new XMLSerializer().serializeToString(response)], { type: 'text/xml' });
                var order_id = orderId
                // Create a temporary link element
                var link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                if (selectedGroupOrderIds.length > 1) {
                    link.download = supplier + "-" + orderId + "-Sammellastschrift.xml";
                } else {
                    link.download = supplier + "-" + orderId + "-Lastschrift.xml";
                }
                // Append the link to the document and trigger the click event
                document.body.appendChild(link);
                link.click();

                // Clean up
                document.body.removeChild(link);
                $("group-order-invoices-for-order-" + orderId + " .expand-trigger a").click();
                var modalSelector = "#order_" + orderId + "_modal";

                // Update the value attribute of checkboxes with IDs starting with "sepa_downloaded" to '1'
                if (selectedGroupOrderIds.length >= 1) {
                    selectedGroupOrderIds.forEach(function (groupOrderId) {
                        var modalSelector = "#group_order_" + groupOrderId;
                        checkbox_element = $(modalSelector + ' input[id^="sepa_downloaded"]');
                        checkbox_element.val('1');
                        checkbox_element.prop('checked', true);
                    });
                } else {
                    $(modalSelector + ' input[id^="sepa_downloaded"]').each(function () {
                        $(this).val('1');
                        $(this).prop('checked', true);
                    });
                }
            },
            error: function (error) {
                // Handle error
                if (error.responseJSON) {
                    alert('AJAX request error:' + "\n" + error.responseJSON.message);
                } else {
                    var errorText = JSON.parse(error.responseText).error;
                    var alertDiv = '<div class="alert fade in alert-error"><button class="close" data-dismiss="alert">×</button>' + errorText + '</div>';
                    $('.page-header').before(alertDiv);
                    $('modal_')
                }
            }
        });
    }
    else {
        var errorText = "Nothing selected";
        var alertDiv = '<div class="alert fade in alert-error"><button class="close" data-dismiss="alert">×</button>' + errorText + '</div>';
        $('.page-header').before(alertDiv);
    }
}

$(document).off('click', '[id^="collective-direct-debit-link-selected-"]').on('click', '[id^="collective-direct-debit-link-selected-"]', function (e) {
    e.preventDefault();
    var input = "group_order_ids_for_order_"
    var orderId = $(this).data("order-id");
    var supplier = $(this).data("supplier");
    if (orderId == undefined) {
        orderId = $(this).data("multi-order-id");
        input = "group_order_ids_for_multi_order_"
    }
    // Extract selected group_order_ids
    var selectedGroupOrderIds = $('input[name^="'+ input + orderId + '"]:checked').map(function () {
        return $(this).val();
    }).get();

    var url = $(this).closest('a').attr('href');
    doTheDownload(selectedGroupOrderIds, orderId, url, supplier, "selected");
});

$(document).off('click', '[id^="collective-direct-debit-link-all-"]').on('click', '[id^="collective-direct-debit-link-all-"]', function (e) {
    e.preventDefault();
    var orderId = $(this).data("order-id");
    var supplier = $(this).data("supplier");
    var url = $(this).closest('a').attr('href');
    doTheDownload([], orderId, url, supplier, "all");
});
