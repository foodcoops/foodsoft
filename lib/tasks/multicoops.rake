# This namespace is used for a collection of tasks to maintain a hosting environment with multiple foodcoops
# This tasks are a kind of wrapper for other tasks. The wrapper makes sure, that the appropriate database and config
# for each foodcoop is used.

namespace :multicoops do
  desc 'Runs a specific rake task for each registered foodcoop, use rake multicoops:run TASK=db:migrate'
  task run: :environment do
    task_to_run = ENV.fetch('TASK', nil)
    last_error = nil
    FoodsoftConfig.each_coop do |coop|
      rake_say "Run '#{task_to_run}' for #{coop}"
      Rake::Task[task_to_run].execute
    rescue StandardError => e
      last_error = e
      ExceptionNotifier.notify_exception(e, data: { foodcoop: coop })
    end
    raise last_error if last_error
  end

  desc 'Runs a specific rake task for a single coop, use rake mutlicoops:run_single TASK=db:migrate FOODCOOP=demo'
  task run_single: :environment do
    task_to_run = ENV.fetch('TASK', nil)
    FoodsoftConfig.select_foodcoop ENV.fetch('FOODCOOP', nil)
    rake_say "Run '#{task_to_run}' for #{ENV.fetch('FOODCOOP', nil)}"
    Rake::Task[task_to_run].execute
  end
end

# Helper
def rake_say(message)
  puts message unless Rake.application.options.silent
end
