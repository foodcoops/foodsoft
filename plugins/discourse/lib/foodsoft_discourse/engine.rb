module FoodsoftDiscourse
  class Engine < ::Rails::Engine
    def default_foodsoft_config(cfg)
      # Extra origins the Discourse SSO handshake may redirect to, besides this
      # foodsoft instance and `discourse_url`. A String or a list of Strings, each a
      # full origin like 'https://forum.example.com' (exact match, no subdomains).
      cfg[:discourse_redirect_hosts] ||= []
    end
  end
end
