class Wikilink < WikiCloth::WikiLinkHandler
  
  def link_attributes_for(page)
    permalink = Page.permalink(page)
    url_options = {:host => FoodsoftConfig[:host], :protocol => FoodsoftConfig[:protocol]}
    url_options.merge!({:port => FoodsoftConfig[:port]}) if FoodsoftConfig[:port]

    if Page.exists?(:permalink => permalink)
     { :href => url_for(:wiki_page_path, permalink: permalink, use_route: :wiki_page) }
    else
      { href: url_for(:new_page_path, title: page, parent: params[:referer]), class: 'new_wiki_link' }
    end
  end

  def section_link(section)
    ""
  end

  def url_for(path_name, options = {})
    Rails.application.routes.url_helpers.send path_name, options.merge({foodcoop: FoodsoftConfig.scope})
  end
end
