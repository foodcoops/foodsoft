class Admin::LinksController < Admin::BaseController
  def index
    @links = Link.ordered
  end

  def new
    @link = Link.new
    render action: :edit
  end

  def create
    @link = Link.new(link_params)
    if @link.save
      index
      render action: :update_links
    else
      render action: :edit
    end
  end

  def edit
    @link = Link.find(params[:id])
  end

  def update
    @link = Link.find(params[:id])

    if @link.update!(link_params)
      index
      render action: :update_links
    else
      render action: :edit
    end
  end

  def destroy
    link = Link.find(params[:id])
    link.destroy!
    redirect_to admin_links_path
  rescue => error
    redirect_to admin_links_path, I18n.t('errors.general_msg', msg: error.message)
  end

  private

  def link_params
    params.require(:link).permit(:name, :url, :workgroup_id, :indirect, :authorization)
  end
end
