require 'routing_filter/base'

module RoutingFilter
  class Foodcoop < Base
    def around_recognize(path, env, &block)
      token = extract_token!(path)                                # remove the token from the beginning of the path
      returning yield do |params|                                 # invoke the given block (calls more filters and finally routing)
        params[:foodcoop] = token if token                        # set recognized token to the resulting params hash
      end
    end

    def around_generate(*args, &block)
      token = args.extract_options!.delete(:foodcoop)             # extract the passed :token option
      token = Foodsoft.env if token.nil?                          # default to Foodsoft.env

      returning yield do |result|
        if token
          url = result.is_a?(Array) ? result.first : result
          prepend_token!(url, token)
        end
      end
    end

    protected

    def extract_token!(path)
      foodcoop = nil
      path.sub! %r(^/([a-zA-Z0-9]*)(?=/|$)) do foodcoop = $1; '' end
      foodcoop
    end

    def prepend_token!(url, token)
      url.sub!(%r(^(http.?://[^/]*)?(.*))) { "#{$1}/#{token}#{$2}" }
    end

  end
end