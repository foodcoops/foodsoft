namespace :multicoops do

  desc 'Runs a specific rake task for each registered foodcoop, use rake multicoops:run db:migrate'
  task :run => :environment do
    task_to_run = ARGV[1]
    FoodsoftConfig.each_coop do |coop|
      puts "Run '#{task_to_run}' for #{coop}"
      Rake::Task[task_to_run].invoke
    end
  end

end