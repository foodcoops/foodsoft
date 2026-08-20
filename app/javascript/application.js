// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@popperjs/core"
import "bootstrap"
import "trix"
import "trix-editor-overrides"
import "@rails/actiontext"
import "@hotwired/turbo-rails"

// prevent turbo from intercepting forms
document.addEventListener('turbo:load', () => {
  document.querySelectorAll('form:not([data-turbo])').forEach(f => f.dataset.turbo = 'false')
})