class Wikilink < WikiCloth::WikiLinkHandler

  def url_for(page, parent = nil)
    if parent
      "/pages/new?title=#{page}&parent=#{parent}"
    else
      "/wiki/#{page}"
    end
  end

  def link_attributes_for(page)
    permalink = Page.permalink(page)
    if Page.exists?(:permalink => permalink)
     { :href => url_for(permalink) }
    else
     { :href => url_for(page, params[:referer]), :class =>  "new_wiki_link"}
    end
  end

  def section_link(section)
    ""
  end
end