(function(window, undefined) {

var CustomizedList = function(id, options, values) {
  var self = this;
  var h = window.ListJsHelpers;
  
  this.searchTimeout = undefined;
  
  var init = {
    start: function(id, options, values) {
      this.defaults(options);
      this.list(id, options, values);
      this.callbacks(options);
    },
    defaults: function(options) {
      options.delayedSearchClass = options.delayedSearchClass || 'delayed-search';
      options.delayedSearchTime = options.delayedSearchTime || 500;
    },
    list: function(id, options, values) {
      self.list = new window.List(id, options, values);
    },
    callbacks: function(options) {
      h.addEvent(h.getByClass(options.delayedSearchClass, self.list.listContainer), 'keyup', self.searchDelayStart);
    }
  };
  
  this.searchDelayStart = function(searchString, columns) {
    // TODO: if keycode corresponds to 'ENTER' ? skip delay
    // TODO: if search is about to be cleared (empty searchString) ? skip delay
    clearTimeout(self.searchTimeout);
    self.searchTimeout = window.setTimeout(function() {self.searchDelayEnd(searchString, columns)}, options.delayedSearchTime);
  }
  
  this.searchDelayEnd = function(searchString, columns) {
    self.list.search(searchString, columns);
  }
  
  init.start(id, options, values);
}

window.CustomizedList = CustomizedList;

})(window);
