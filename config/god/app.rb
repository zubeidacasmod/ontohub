require File.expand_path('../sidekiq_workers',  __FILE__)

SidekiqWorkers.configure do
  if ENV['RAILS_ENV']=='production'
    # one worker for the hets queue
    watch 'hets', 2
    
    # one worker for the default queue
    watch 'default', 5
  else
    # one worker for all queues
    watch %w( hets default ), 1
  end
end
