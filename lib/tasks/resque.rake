require "resque/tasks"

def run_worker(queue, count = 1)
  puts "Starting #{count} worker(s) with QUEUE: #{queue}"
  ops = {:pgroup => true, :err => ["log/resque_worker_foodsoft_notifier.log", "a"], 
                          :out => ["log/resque_worker_foodsoft_notifier.log", "a"]}
  env_vars = {"QUEUE" => queue.to_s, "PIDFILE" => "tmp/pids/resque_worker_foodsoft_notifier.pid"}
  count.times {
    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    pid = spawn(env_vars, "bundle exec rake resque:work", ops)
    Process.detach(pid)
  }
end

namespace :resque do
  task :setup => :environment

  desc "Restart running workers"
  task :restart_workers do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end
  
  desc "Quit running workers"
  task :stop_workers do
    pids = File.read('tmp/pids/resque_worker_foodsoft_notifier.pid').split("\n")
    if pids.empty?
      puts "No workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    end
  end
  
  desc "Start workers"
  task :start_workers do
    run_worker("foodsoft_notifier") 
  end
end
