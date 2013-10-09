// for use with listjs 0.2.0
// https://github.com/javve/list.js

(function(window, undefined) {

window.List.prototype.plugins.reset = function(locals, options) {
  var list = this;
  
  var init = {
    start: function(options) {
      this.defaults(options);
      this.callbacks(options);
    },
    defaults: function(options) {
      options.highlightClass = options.highlightClass || 'btn-primary';
      options.resetSearchClass = options.resetSearchClass || 'reset-search';
      options.resettableClass = options.resettableClass || 'resettable';
    },
    callbacks: function(options) {
      $('.' + options.resetSearchClass, list.listContainer).click(list.resetSearch);
      list.on('updated', list.highlightResetButton);
      
      $(list.listContainer).on('updateComing', function() {
        list.highlightResetButton(false);
      });
    }
  };
  
  this.highlightResetButton = function(highlightEnabled) {
    highlightEnabled = (undefined === highlightEnabled) ? (list.searched) : (highlightEnabled);
    $('.' + options.resetSearchClass, list.listContainer).toggleClass(options.highlightClass, highlightEnabled);
  };
  
  this.resetSearch = function() {
    $('.' + options.resettableClass, list.listContainer).val('');
    list.search('');
  };
  
  init.start(options);
}

})(window);
