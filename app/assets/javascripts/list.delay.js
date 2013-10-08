// for use with listjs 0.2.0
// https://github.com/javve/list.js

(function(window, undefined) {

window.List.prototype.plugins.delay = function(locals, options) {
  var list = this;
  
  this.searchTimeout = undefined;
  
  var init = {
    start: function(options) {
      this.defaults(options);
      this.callbacks(options);
      this.onload(options);
    },
    defaults: function(options) {
      options.delayedSearchClass = options.delayedSearchClass || 'delayed-search';
      options.delayedSearchTime = options.delayedSearchTime || 500;
    },
    callbacks: function(options) {
      $('.' + options.delayedSearchClass, list.listContainer).keyup(list.searchDelayStart);
    },
    onload: function(options) {
      var initialSearchTerm = $('.' + options.delayedSearchClass, list.listContainer).val();
      if('' != initialSearchTerm) {
        list.search(initialSearchTerm);
      }
    }
  };
  
  this.searchDelayStart = function(searchString, columns) {
    // TODO: if keycode corresponds to 'ENTER' ? skip delay
    clearTimeout(list.searchTimeout);
    list.searchTimeout = window.setTimeout(
      function() {list.searchDelayEnd(searchString, columns)},
      options.delayedSearchTime
    );
    
    $(list.listContainer).trigger('updateComing');
  };
  
  this.searchDelayEnd = function(searchString, columns) {
    list.search(searchString, columns);
  };
  
  init.start(options);
}

})(window);
