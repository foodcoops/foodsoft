require 'net/http'

class LinksController < ApplicationController
  def show
    link = Link.find(params[:id])
    url = link.url

    return deny_access if link.workgroup && !current_user.role_admin? && !link.workgroup.member?(current_user)

    if link.indirect
      uri = URI.parse url
      request = Net::HTTP::Get.new uri
      request['Authorization'] = link.authorization if link.authorization
      result = Net::HTTP.start uri.host, uri.port, use_ssl: uri.scheme == 'https' do |http|
        http.request request
      end

      url = result.header['Location']

      return redirect_to root_url, alert: t('.indirect_no_location') unless url
    end

    redirect_to url, status: :found, allow_other_host: true
  end
end
