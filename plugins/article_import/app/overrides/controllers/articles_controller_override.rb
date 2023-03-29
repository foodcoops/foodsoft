ArticlesController.class_eval do
  def parse_upload
    uploaded_file = params[:articles]['file'] or raise I18n.t('articles.controller.parse_upload.no_file')
    type = params[:articles]['type']
    options = { filename: uploaded_file.original_filename }
    options[:outlist_absent] = (params[:articles]['outlist_absent'] == '1')
    options[:convert_units] = (params[:articles]['convert_units'] == '1')
    options[:update_category] = (params[:articles]['update_category'] == '1')

    @updated_article_pairs, @outlisted_articles, @new_articles = @supplier.sync_from_file uploaded_file.tempfile, type, options
    if @updated_article_pairs.empty? && @outlisted_articles.empty? && @new_articles.empty?
      redirect_to supplier_articles_path(@supplier), :notice => I18n.t('articles.controller.parse_upload.notice')
    end
    @ignored_article_count = 0
  rescue => error
    redirect_to upload_supplier_articles_path(@supplier), :alert => I18n.t('errors.general_msg', :msg => error.message)
  end
end
