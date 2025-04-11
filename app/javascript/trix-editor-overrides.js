// app/javascript/trix-editor-overrides.js
window.addEventListener("trix-file-accept", function(event) {
  if (event.file.size > 1024 * 1024 * 512) {
    event.preventDefault()
    alert(I18n.t('js.trix_editor.file_size_alert'))
  }
})