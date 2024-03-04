require 'filemagic'

class DocumentsController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftDocuments }

  def index
    sort = if params['sort']
             case params['sort']
             when 'name' then 'folder DESC, name'
             when 'created_at' then 'created_at'
             when 'name_reverse' then 'folder, name DESC'
             when 'created_at_reverse' then 'created_at DESC'
             end
           else
             'folder DESC, name'
           end
    sort = Arel.sql(sort) # this is okay as we don't use user params directly
    @documents = Document.where(parent: @document).page(params[:page]).per(@per_page).order(sort)
  end

  def new
    @document = Document.new parent_id: params[:document_id]
    @document.folder = params[:type] == 'folder'
  end

  def create
    @document = Document.new name: params[:document][:name]
    @document.parent = Document.find_by_id(params[:document][:parent_id])
    @document.attachment = params[:document][:attachment]
    if !@document.attachment.nil?
      if @document.name.empty?
        name = File.basename(@document.attachment.filename.to_s)
        @document.name = name.gsub(/[^\w.-]/, '_')
      end
    end
    @document.created_by = current_user
    @document.folder = !params[:document].has_key?(:attachment)
    @document.save!
    redirect_to @document.parent || documents_path, notice: t('.notice')
  rescue StandardError => e
    redirect_to @document.parent || documents_path, alert: t('.error', error: e.message)
  end

  def update
    @document = Document.find(params[:id])
    @document.update_attribute(:parent_id, params[:parent_id])
    redirect_to @document.parent || documents_path, notice: t('.notice')
  rescue StandardError => e
    redirect_to @document.parent || documents_path, alert: t('errors.general_msg', msg: e.message)
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.created_by == current_user or current_user.role_admin?
      @document.delete_attachment
      @document.destroy
      redirect_to documents_path, notice: t('.notice')
    else
      redirect_to documents_path, alert: t('.no_right')
    end
  rescue StandardError => e
    redirect_to documents_path, alert: t('.error', error: e.message)
  end

  def show
    @document = Document.find(params[:id])
    if @document.file?
      send_data(@document.attachment.download, filename: @document.name, type: @document.attachment.blob.content_type)
    else
      index
      render :index
    end
  end

  def move
    @document = Document.find(params[:document_id])
  end

end
