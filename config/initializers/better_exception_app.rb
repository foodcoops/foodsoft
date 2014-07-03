if defined? BetterExceptionApp
  # use error template
  BetterExceptionApp::HttpErrorsController.layout 'error'

  # render ajax errors as json
  #class BetterExceptionApp::HttpErrorsController
  #  before_filter :return_js_error_as_json
  #  protected
  #  def return_js_error_as_json
  #    request.format = :json if request.format.symbol == :js
  #  end
  #end

  # @todo don't show default error page; after initialize do
  #BetterExceptionApp::HttpError.error_files_paths.clear
end
