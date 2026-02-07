class Api::V1::NavigationsController < Api::BaseController
  def show
    # we don't use active_model_serializers here, because source is a Hash
    render json: { navigation: transform(navigation) }
  end

  private

  def navigation
    render_navigation(renderer: :json, as_hash: true)
  end

  def transform(items)
    items.map do |item|
      r = {}
      r[:name] = item[:name]
      r[:url] = request.base_url + item[:url] if item[:url] && item[:url] != '#'
      r[:items] = transform(item[:items]) if item[:items]
      r
    end
  end
end
