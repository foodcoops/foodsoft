require_relative '../spec_helper'

feature 'JS environment diagnostics', :js do
  let(:user) { create(:user, groups: [create(:workgroup, role_article_meta: true)]) }
  let(:supplier) { create(:supplier) }

  before do
    login user
    visit supplier_articles_path(supplier_id: supplier.id)
  end

  it 'dumps browser JS environment state' do
    puts "\n=== typeof bootstrap: #{page.evaluate_script('typeof bootstrap')}"

    importmap = page.evaluate_script("document.querySelector('script[type=\"importmap\"]')?.textContent")
    puts "=== importmap tag: #{importmap.inspect}"

    if importmap
      pin_statuses = page.evaluate_script(<<~JS)
        (() => {
          var imports = JSON.parse(document.querySelector('script[type="importmap"]').textContent).imports || {};
          var out = [];
          Object.keys(imports).forEach(function (name) {
            var url = imports[name];
            try {
              var xhr = new XMLHttpRequest();
              xhr.open('GET', url, false);
              xhr.send();
              out.push(name + ' -> HTTP ' + xhr.status + ' ' + url);
            } catch (e) {
              out.push(name + ' -> FETCH ERROR ' + e);
            }
          });
          return out.join('\\n');
        })()
      JS
      puts "=== importmap pin fetch statuses:\n#{pin_statuses}"
    end

    requested_assets = page.evaluate_script(<<~JS)
      performance.getEntriesByType('resource')
        .map(function (e) { return e.name; })
        .filter(function (n) { return n.indexOf('/assets/') !== -1; })
        .join('\\n')
    JS
    puts "=== requested /assets URLs:\n#{requested_assets}"

    script_types = page.evaluate_script(<<~JS)
      Array.from(document.scripts)
        .map(function (s) { return s.type || 'classic'; })
        .join(', ')
    JS
    puts "=== script types in document: #{script_types}"

    expect(page).to have_content(supplier.name)
    expect(page.evaluate_script('typeof bootstrap')).to eq('object')
  end
end
