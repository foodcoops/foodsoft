class Api::V1::ConfigsController < Api::V1::BaseController

  before_action :authenticate

  def show
    render json: FoodsoftConfig, serializer: ConfigSerializer, root: 'config'
  end

end
