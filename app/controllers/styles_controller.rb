# Foodcoop-specific styling
class StylesController < ApplicationController
  skip_before_action :authenticate

  # renders foodcoop css, or 404 if not configured
  #
  # When requested with the parameter +md5+, the result is returned
  # with an expiry time of a week, to leverage caching.
  def foodcoop
    css = FoodsoftConfig[:custom_css]
    if css.blank?
      render text: nil, content_type: 'text/css', status: 404
    else
      expires_in 1.week, public:true if params[:md5].present?
      render text: css, content_type: 'text/css'
    end
  end
end
