require 'net/http'

class LinksController < ApplicationController
  def show
    link = Link.find(params[:id])
    url = link.url

    if link.workgroup && !current_user.role_admin? && !link.workgroup.member?(current_user)
      return deny_access
    end

    if link.indirect
      uri = URI.parse url
      request = Net::HTTP::Get.new uri
      request['Authorization'] = link.authorization if link.authorization
      result = Net::HTTP.start uri.host, uri.port, use_ssl: uri.scheme == 'https' do |http|
        http.request request
      end

      url = result.header['Location']

      unless url
        return redirect_to root_url, alert: t('.indirect_no_location')
      end
    end

    redirect_to url, status: 302
  end
end
