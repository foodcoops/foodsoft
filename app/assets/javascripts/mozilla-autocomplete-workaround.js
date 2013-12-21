// Workaround for only Mozilla (Firefox) autocompleting password even though autocomplete=off
if (window.mozIndexedDB) {

    $(function() {
        // after loading the page
        // basic idea from http://verysimple.com/2007/03/07/forcing-firefox-to-obey-autocompleteoff-for-password-fields
        var passwd = $('form[autocomplete=off] input[type=password], input[type=password][autocomplete=off]');
        setTimeout(function() {
            passwd.val('');
        }, 100);

        // the password can still be overwritten when the username field gets and loses focus :/
        $.unique(passwd.closest('form')).each(function() {
            var fields = $(this).find('input,button,textarea,select');
            for (var i=0; i<fields.length; i++) {
                var passwd = $(fields[i]);
                if (passwd.prop('tagName')!='INPUT' || passwd.attr('type').toUpperCase()!='PASSWORD') continue;
                if (i==0) break;
                var field = $(fields[i-1]);
                if (passwd.prop('tagName')!='INPUT') break;
                firefox_autocomplete_focus_workaround(field, passwd);
            }
        });

        function firefox_autocomplete_focus_workaround(field, passwd) {
            // we have a username field; store old password when it gets the focus
            field.on('focusin', function() {
                passwd.data('old-val', passwd.val());
            });
            // and set the old value when it loses the focus
            field.on('focusout', function() {
                setTimeout(function() {
                    passwd.val(passwd.data('old-val'));
                    passwd.removeData('old-val');
                }, 100);
            });
        }
    });

}
