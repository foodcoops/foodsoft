namespace :multicoops do

  desc 'Runs a specific rake task for each registered foodcoop, use rake multicoops:run db:migrate'
  task :run => :environment do
    task_to_run = ARGV[1]
    FoodsoftConfig.each_coop do |coop|
      puts "Run '#{task_to_run}' for #{coop}"
      Rake::Task[task_to_run].execute
    end
  end

  desc 'Runs a specific rake task for a single coop, use rake mutlicoops:run_single db:migrate FOODCOOP=demo'
  task :run_single => :environment do
    task_to_run = ARGV[1]
    FoodsoftConfig.select_foodcoop ENV['FOODCOOP']
    puts "Run '#{task_to_run}' for #{ENV['FOODCOOP']}"
    Rake::Task[task_to_run].execute
  end

end
