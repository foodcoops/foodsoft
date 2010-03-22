class Wikilink < WikiCloth::WikiLinkHandler
  include ActionController::UrlWriter # To use named routes
  
  def link_attributes_for(page)
    permalink = Page.permalink(page)
    url_options = {:host => Foodsoft.config[:host], :protocol => Foodsoft.config[:protocol]}
    url_options.merge!({:port => Foodsoft.config[:port]}) if Foodsoft.config[:port]

    if Page.exists?(:permalink => permalink)
     { :href => url_for(url_options.merge({:controller => "pages", :action => "show", 
                                          :permalink => permalink, :use_route => :wiki_page})) }
    else
     { :href => url_for(url_options.merge({:controller => "pages", :action => "new", 
                                          :title => page, :parent => params[:referer]})), :class =>  "new_wiki_link"}
    end
  end

  def section_link(section)
    ""
  end
end
