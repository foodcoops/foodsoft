class Api::V1::ConfigsController < Api::V1::BaseController

  before_action ->{ doorkeeper_authorize! 'config:user', 'config:read', 'config:write' }

  def show
    render json: FoodsoftConfig, serializer: ConfigSerializer, root: 'config'
  end

end
