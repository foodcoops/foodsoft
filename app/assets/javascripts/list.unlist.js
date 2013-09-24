/*******************************************************************************
********************************************************************************

The following code is a modification of list.js. It was created by copy-pasting
the original code with the copyright notice below.

********************************************************************************
*******************************************************************************/



/*******************************************************************************
Begin copyright notice of the original code
*******************************************************************************/

/*
ListJS Beta 0.2.0
By Jonny Strömberg (www.jonnystromberg.com, www.listjs.com)

OBS. The API is not frozen. It MAY change!

License (MIT)

Copyright (c) 2011 Jonny Strömberg http://jonnystromberg.com

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

/*******************************************************************************
End copyright notice of the original code
*******************************************************************************/



/*******************************************************************************
Begin copy-pasted and modified code
*******************************************************************************/

// * template engine which adds class 'unlisted' instead of removing from DOM
// * especially useful in case of formulars
// * uses jQuery's $
List.prototype.templateEngines.unlist = function(list, settings) {
    var listSource = ListJsHelpers.getByClass(settings.listClass, list.listContainer, true),
        itemSource = getItemSource(settings.item),
        templater = this;

  var init = {
    start: function(options) {
      this.defaults(options);
      this.callbacks(options);
    },
    defaults: function(options) {
      options.listHeadingsClass = options.listHeadingsClass || 'list-heading';
    },
    callbacks: function(options) {
      list.on('updated', templater.updateListHeadings);
    }
  };

    function getItemSource(item) {
        if (item === undefined) {
            var nodes = listSource.childNodes,
                items = [];

            for (var i = 0, il = nodes.length; i < il; i++) {
                // Only textnodes have a data attribute
                if (nodes[i].data === undefined) {
                    return nodes[i];
                }
            }
            return null;
        } else if (item.indexOf("<") !== -1) { // Try create html element of list, do not work for tables!!
            var div = document.createElement('div');
            div.innerHTML = item;
            return div.firstChild;
        } else {
            return document.getElementById(settings.item);
        }
    }

    var ensure = {
        created: function(item) {
            if (item.elm === undefined) {
                templater.create(item);
            }
        }
    };

    /* Get values from element */
    this.get = function(item, valueNames) {
        ensure.created(item);
        var values = {};
        for(var i = 0, il = valueNames.length; i < il; i++) {
            var elm = ListJsHelpers.getByClass(valueNames[i], item.elm, true);
            values[valueNames[i]] = elm ? elm.innerHTML : "";
        }
        return values;
    };

    /* Sets values at element */
    this.set = function(item, values) {
        ensure.created(item);
        for(var v in values) {
            if (values.hasOwnProperty(v)) {
                // TODO speed up if possible
                var elm = ListJsHelpers.getByClass(v, item.elm, true);
                if (elm) {
                    elm.innerHTML = values[v];
                }
            }
        }
    };

    this.create = function(item) {
        if (item.elm !== undefined) {
            return;
        }
        /* If item source does not exists, use the first item in list as
        source for new items */
        var newItem = itemSource.cloneNode(true);
        newItem.id = "";
        item.elm = newItem;
        templater.set(item, item.values());
    };
    this.remove = function(item) {
        listSource.removeChild(item.elm);
    };
    this.show = function(item) {
        ensure.created(item);
        listSource.appendChild(item.elm); // append item (or move it to the end)
        $(item.elm).removeClass('unlisted');
    };
    this.hide = function(item) {
        ensure.created(item);
        $(item.elm).addClass('unlisted');
        listSource.appendChild(item.elm);
    };
    this.clear = function() {
        $(listSource.childNodes).addClass('unlisted');
    };
  
  this.updateListHeadings = function() {
    var headSel = '.' + settings.listHeadingsClass;
    
    $(headSel, listSource).each(function() {
      if( $(this).nextUntil(headSel, ':not(.unlisted)').length ) {
        $(this).removeClass('unlisted');
      }
    });
  };
  
  init.start(settings);
};

/*******************************************************************************
End copy-pasted and modified code
*******************************************************************************/
