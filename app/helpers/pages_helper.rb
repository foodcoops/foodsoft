module PagesHelper

  def wiki_link(wiki_words, link_text = nil)
    permalink = Page.permalink(wiki_words)
    if Page.exists?(:permalink => permalink)
      link_to((link_text || wiki_words), wiki_page_url(permalink))
    else
      link_to((link_text || wiki_words), wiki_page_url(permalink), :class => "new_wiki_link")
    end
  end

  def build_internal_links(body)
    body.gsub(/\[\[(.*?)(\|(.*?))?\]\]/) { wiki_link($1, $3) }
  end

  def build_anchors(body)
    body.gsub(/(<h\d{1}>(.+)<\/h\d{1}>)/) do
      header = $1
      token = $2.downcase.gsub(' ', '-')
      "<a name='#{token}'> </a>#{header}"
    end
  end

  def wikified_body(body)
    body = Wikitext::Parser.new.parse body
    build_anchors(body)
  end
  
  def wiki_header(body)
    body.gsub(/^(={1,6})\s*(.*)\s*={1,6}$/) { "h#{$1.size}. #{$2}" }
  end

  def generate_toc(body)
    toc = ""
    body.gsub(/<h(\d{1})>(.+)<\/h\d{1}>/) do
      number = $1.to_i - 1
      name = $2

      toc << "#" * number + " #{name}\n"
    end
    logger.debug("TOC: #{toc}")
    toc = Wikitext::Parser.new.parse toc

    toc.gsub(/<li>([^<>\n]*)/) do
      name = $1
      token = name.downcase.gsub(' ', '-')

      "<li><a href='##{token}'>#{name}</a>"
    end
  end

end
