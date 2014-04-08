# Allow loading multiple seeds
#   Tried using seedbank, but that supposes all seeds are loaded, while
#   we want to have different options to choose from (and they can't
#   be loaded at the same time).
require 'pathname'

namespace :db do
  namespace :seed do
    Dir.glob(Rails.root.join('db/seeds/*.seeds.rb')).each do |seedfile|
      desc "Load the seed data from #{Pathname.new(seedfile).relative_path_from(Rails.root)}"
      task File.basename(seedfile, '.seeds.rb') => :environment do
        require_relative seedfile
      end
    end
  end
end
