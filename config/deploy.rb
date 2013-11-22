require 'bundler/capistrano'
require 'rvm/capistrano'
require 'capistrano-unicorn'
load 'deploy/assets'

set :default_env, 'production'
set :rails_env, ENV['rails_env'] || ENV['RAILS_ENV'] || default_env
set :keep_releases, 5

set :application, "tradebitcoin-online"
set :repository,  "git@github.com:NetVersaLLC/bitcoin-central.git"
set :normalize_asset_timestamps, false # github fix
set :ssh_options, { :forward_agent => true }

set :scm, :git
set :deploy_to, "/home/tradeonline/app"

set :use_sudo, false

set :user, "tradeonline"


def production_prompt
  puts "\n\e[0;31m   ######################################################################"
  puts "   #\n   #       Are you REALLY sure you want to deploy to production?"
  puts "   #\n   #               Enter y/N + enter to continue\n   #"
  puts "   ######################################################################\e[0m\n"
  proceed = STDIN.gets[0..0] rescue nil
  exit unless proceed == 'y' || proceed == 'Y'
end

def staging_prompt
  puts "\n\e[0;31m   ######################################################################"
  puts "   #\n   #       Deploy to staging?     "
  puts "   ######################################################################\e[0m\n"
  proceed = STDIN.gets[0..0] rescue nil
  exit unless proceed == 'y' || proceed == 'Y'
end

task :production do
  #production_prompt
  #set  :rails_env ,'production'
  #set  :branch    ,'production'
  #set  :host      ,'test.tradebitcoin.com'
  #role :app       ,host
  #role :web       ,host
  #role :db        ,host, :primary => true
end

task :staging do
  staging_prompt
  set  :rails_env ,'staging'
  set  :branch    ,'rails4'
  set  :host      ,'test.tradebitcoin.com'
  role :app       ,host
  role :web       ,host
  role :db        ,host, :primary => true
end

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
#set :deploy_via, :remote_cache
set :git_enable_submodules, 1

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
  end

  desc 'Running migrations'
  task :migrations, :roles => :db do
    run "cd #{release_path} && bundle exec rake db:migrate RAILS_ENV=#{rails_env}"
  end

  #desc 'Building assets'
  #task :assets do
  #  run "cd #{release_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
  #end
end

task :copy_production_configurations do
  %w{database bitcoin recaptcha liberty_reserve google_analytics pecunix yubico banks}.each do |c|
    run "cp #{shared_path}/config/#{c}.yml #{release_path}/config/#{c}.yml"
  end
end

task :symlink_bitcoin_bin_dir do
  run "ln -s #{shared_path}/bin #{release_path}/public/bin"
end



#before 'deploy:assets:precompile', :copy_production_configurations

after 'deploy', 'deploy:migrations'
after 'deploy:update_code', "deploy:update_crontab"
after "deploy:update_crontab", :symlink_bitcoin_bin_dir

#after 'deploy:restart', 'unicorn:reload' # app IS NOT preloaded
after 'deploy:restart', 'unicorn:restart'  # app preloaded