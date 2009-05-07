module PagesHelper

  def wikified_body(body)
    r = BlueCloth.new(body)
    r.gsub!(/\[\[(.*?)(\|(.*?))?\]\]/) { wiki_link($1, $3) }
    sanitize r.to_html
    r.to_html
  end

  def wiki_link(wiki_words, link_text = nil)
    permalink = wiki_words.downcase.gsub(' ', '-')
    if Page.exists?(:permalink => permalink)
      link_to((link_text || wiki_words), wiki_page_url(permalink))
    else
      link_to((link_text || wiki_words), wiki_page_url(permalink), :class => "new_wiki_link")
    end
  end
end
