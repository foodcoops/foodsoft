require 'init'
include WikiCloth

class CustomLinkHandler < WikiLinkHandler
  def include_resource(resource,options=[])
    case resource
    when "date"
      Time.now.to_s
    else
      # default behavior
      super(resource,options)
    end
  end
  def url_for(page)
    "javascript:alert('You clicked on: #{page}');"
  end
  def link_attributes_for(page)
     { :href => url_for(page) }
  end
end
@wiki = WikiCloth::WikiCloth.new({ 
  :data => "<nowiki>{{test}}</nowiki> ''Hello {{test}}!''\n",
  :params => { "test" => "World" } })
puts @wiki.to_html
@wiki = WikiCloth::WikiCloth.new({ 
  :params => { "PAGENAME" => "Testing123" }, 
  :link_handler => CustomLinkHandler.new, 
  :data => "\n[[Hello World]] From {{ PAGENAME }} on {{ date }}\n" 
})
puts @wiki.to_html

Dir.glob("sample_documents/*.wiki").each do |x|

  start_time = Time.now
  out_name = "#{x}.html"
  data = File.open(x) { |x| x.read }

  tmp = WikiCloth::WikiCloth.new()
  tmp.load(data, { "PAGENAME" => "HelloWorld" })
  out = tmp.render({ :output => :html })
  out = "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\" dir=\"ltr\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><link rel=\"stylesheet\" href=\"default.css\" type=\"text/css\" /></head><body>#{out}</body></html>"

  File.open(out_name, "w") { |x| x.write(out) }
  end_time = Time.now
  puts "#{out_name}: Completed (#{end_time - start_time} sec) | External Links: #{tmp.link_handler.external_links.size} -- References: #{tmp.link_handler.references.size}"

end

