module FoodsoftWiki
  class WikiParser < WikiCloth::Parser

    template do |template|
      Foodsoft::ExpansionVariables.get(template)
    end

    url_for do |page|
      url_for page
    end

    link_attributes_for do |page|
      permalink = Page.permalink(page)
      if Page.exists?(:permalink => permalink)
        { href: url_for(:wiki_page_path, permalink: permalink) }
      else
        { href: url_for(:new_page_path, title: page, parent: params[:referer]), class: 'new_wiki_link' }
      end
    end

    section_link do |section|
      ""
    end

    def to_html(render_options = {})
      # workaround for wikicloth 0.8.0 https://github.com/nricciar/wikicloth/pull/59
      render_options[:locale] ||= I18n.locale
      super(render_options)
    end


    private

    def url_for(path_name, options={})
      Rails.application.routes.url_helpers.send path_name, options.merge({foodcoop: FoodsoftConfig.scope})
    end

  end
end
