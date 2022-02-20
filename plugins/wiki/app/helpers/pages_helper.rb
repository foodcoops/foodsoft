module PagesHelper
  include WikiCloth

  def rss_meta_tag
    tag.link(rel: "alternate", type: "application/rss+xml", title: "RSS", href: all_pages_rss_url).html_safe
  end

  def wikified_body(body, title = nil)
    FoodsoftWiki::WikiParser.new(data: body + "\n", params: { referer: title }).to_html(noedit: true).html_safe
  rescue => e
    # try the following with line breaks: === one === == two == = three =
    content_tag :span, class: 'alert alert-error' do
      I18n.t '.wikicloth_exception', :msg => e
    end.html_safe
  end

  def link_to_wikipage(page, text = nil)
    if text == nil
      link_to page.title, wiki_page_path(:permalink => page.permalink)
    else
      link_to text, wiki_page_path(:permalink => page.permalink)
    end
  end

  def link_to_wikipage_by_permalink(permalink, text = nil)
    unless permalink.blank?
      page = Page.find_by_permalink(permalink)
      if page.nil?
        if text.nil?
          link_to permalink, new_page_path(:title => permalink)
        else
          link_to text,  new_page_path(:title => permalink)
        end
      else
        link_to_wikipage(page, text)
      end
    end
  end

  def generate_toc(body)
    toc = String.new
    body.gsub(/^([=]{1,6})\s*(.*?)\s*(\1)/) do
      number = $1.length - 1
      name = $2

      toc << "*" * number + " #{name}\n"
    end

    unless toc.blank?
      FoodsoftWiki::WikiParser.new(data: toc).to_html.gsub(/<li>([^<>\n]*)/) do
        name = $1
        anchor = name.gsub(/\s/, '_').gsub(/[^a-zA-Z_]/, '')
        "<li><a href='##{anchor}'>#{name.truncate(20)}</a>"
      end.html_safe
    end
  end

  def parent_pages_to_select(current_page)
    unless current_page.homepage? # Homepage is the page trees root!
      Page.non_redirected.reject { |p| p == current_page || p.ancestors.include?(current_page) }
    else
      Array.new
    end
  end

  # return url for all_pages rss feed
  def all_pages_rss_url(options = {})
    token = TokenVerifier.new(['wiki', 'all']).generate
    all_pages_url({ :format => 'rss', :token => token }.merge(options))
  end
end
