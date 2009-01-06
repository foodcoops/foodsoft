desc "Checks your app and gently warns you if you are using deprecated code." 
task :deprecated => :environment do
  deprecated = {
    '@params'    => 'Use params[] instead',
    '@session'   => 'Use session[] instead',
    '@flash'     => 'Use flash[] instead',
    '@request'   => 'Use request[] instead',
    '@env' => 'Use env[] instead',
    'find_all\([^_]\|$\)'   => 'Use find(:all) instead',
    'find_first' => 'Use find(:first) instead',
    'render_partial' => 'Use render :partial instead',
    'component'  => 'Use of components are frowned upon',
    'paginate'   => 'The default paginator is slow. Writing your own may be faster',
    'start_form_tag'   => 'Use form_for instead',
    'end_form_tag'   => 'Use form_for instead',
    ':post => true'   => 'Use :method => :post instead'
  }

  deprecated.each do |key, warning|
    puts '--> ' + key
    output = `cd '#{File.expand_path('app', RAILS_ROOT)}' && grep -n --exclude=*.svn* --exclude=.#* -r '#{key}' *`
    unless output =~ /^$/
      puts "  !! " + warning + " !!" 
      puts '  ' + '.' * (warning.length + 6)
      puts output
    else
      puts "  Clean! Cheers for you!" 
    end
    puts
  end
end