class Api::V1::ConfigsController < Api::V1::BaseController

  def show
    render json: FoodsoftConfig, serializer: ConfigSerializer, root: 'config'
  end

end
