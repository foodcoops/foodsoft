module PagesHelper
  include WikiCloth

#  def build_anchors(body)
#    body.gsub(/(<h\d{1}>(.+)<\/h\d{1}>)/) do
#      header = $1
#      token = $2.downcase.gsub(' ', '-')
#      "<a name='#{token}'> </a>#{header}"
#    end
#  end

  def wikified_body(body, title = nil)
    WikiCloth.new({:data => body+"\n", :link_handler => Wikilink.new, :params => {:referer => title}}).to_html
  end

  def link_to_wikipage(page, text = nil)
    if text == nil
      link_to page.title, "/wiki/#{page.title}"
    else
      link_to text, "/wiki/#{page.title}"
    end
  end


  def link_to_wikipage_by_permalink(permalink, text = nil)
    unless permalink.blank?
      page = Page.find_by_permalink(permalink)
      if page.nil?
        if text.nil?
          link_to permalink,  new_page_path(:title => permalink)
        else
          link_to text,  new_page_path(:title => permalink)
        end
      else
        link_to_wikipage(page, text)
      end
    end
  end
#  def generate_toc(body)
#    toc = ""
#    body.gsub(/^([=]{1,6})\s*(.*?)\s*(\1)/) do
#      number = $1.length - 1
#      name = $2
#
#      toc << "#" * number + " #{name}\n"
#    end
#    toc = WikiCloth.new({:data => toc, :link_handler => Wikilink.new}).to_html
#
#    toc.gsub(/<li>([^<>\n]*)/) do
#      name = $1
#      token = name.downcase.gsub(' ', '-')
#
#      "<li><a href='##{token}'>#{name}</a>"
#    end
#  end

end
