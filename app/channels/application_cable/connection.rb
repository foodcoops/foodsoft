module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include Concerns::AuthApi

    def connect
      FoodsoftConfig.select_multifoodcoop request.params[:foodcoop]
      reject_unauthorized_connection unless valid_api_key?
    end
  end
end
