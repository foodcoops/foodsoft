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
      this.onload(options);
    },
    defaults: function(options) {
      options.delayedSearchClass = options.delayedSearchClass || 'delayed-search';
      options.delayedSearchTime = options.delayedSearchTime || 500;
      options.highlightClass = options.highlightClass || 'btn-primary';
      options.resetSearchClass = options.resetSearchClass || 'reset-search';
    },
    list: function(id, options, values) {
      self.list = new window.List(id, options, values);
    },
    callbacks: function(options) {
      var resetSearchButton = h.getByClass(options.resetSearchClass, self.list.listContainer);
      $(resetSearchButton).click(self.resetSearch);
      self.list.on('updated', self.highlightResetButton);
      
      var delayedSearchInput = h.getByClass(options.delayedSearchClass, self.list.listContainer);
      $(delayedSearchInput).keyup(self.searchDelayStart);
    },
    onload: function(options) {
      var initialSearchTerm = $('.' + options.delayedSearchClass + ', .' + options.searchClass, self.list.listContainer).val();
      if('' != initialSearchTerm) {
        self.list.search(initialSearchTerm);
      }
    }
  };
  
  this.searchDelayStart = function(searchString, columns) {
    // TODO: if keycode corresponds to 'ENTER' ? skip delay
    clearTimeout(self.searchTimeout);
    self.searchTimeout = window.setTimeout(function() {self.searchDelayEnd(searchString, columns)}, options.delayedSearchTime);
    
    var resetSearchButton = h.getByClass(options.resetSearchClass, self.list.listContainer);
    $(resetSearchButton).removeClass(options.highlightClass);
  }
  
  this.searchDelayEnd = function(searchString, columns) {
    self.list.search(searchString, columns);
  }
  
  this.highlightResetButton = function() {
    var resetSearchButton = h.getByClass(options.resetSearchClass, self.list.listContainer);
    $(resetSearchButton).toggleClass(options.highlightClass, self.list.searched);
  }
  
  this.resetSearch = function() {
    $('.' + options.delayedSearchClass + ', .' + options.searchClass, self.list.listContainer).val('');
    self.list.search('');
  }
  
  init.start(id, options, values);
}

window.CustomizedList = CustomizedList;

})(window);
