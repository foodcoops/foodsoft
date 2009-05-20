module PagesHelper

  def wikified_body(body)
    r = RedCloth.new(generate_anchors(body))
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

  def generate_toc(body)
    toc = ""
    body.gsub(/^\s*h([1-6])\.\s+(.*)/) do
      number = $1
      name = $2
      header = name.downcase.gsub(' ', '-')
      toc << '#' * number.to_i + ' "' + name + '":#' + header + "\n"
    end
    RedCloth.new(toc).to_html
  end

  def generate_anchors(body)
    body.gsub(/^\s*h([1-6])\.\s+(.*)/) do
      number = $1
      name = $2
      header = name.downcase.gsub(' ', '-')
      "\nh#{number}. #{name}<a name ='#{header}'> </a>"
    end
  end

end
