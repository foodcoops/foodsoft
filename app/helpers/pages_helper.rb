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

  def link_to_wikipage(page)
    link_to page.title, "/wiki/#{page.title}"
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
