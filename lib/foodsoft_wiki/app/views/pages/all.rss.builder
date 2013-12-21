xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title FoodsoftConfig[:name] + " Wiki"
    xml.description ""
    xml.link FoodsoftConfig[:homepage]

    for page in @pages
      xml.item do
        xml.title page.title
        xml.description page.diff
        xml.author User.find(page.updated_by).display
        xml.pubDate page.updated_at.to_s(:rfc822)
        xml.link wiki_page_path(page.permalink)
        xml.guid wiki_page_path(page.permalink)
      end
    end
  end
end