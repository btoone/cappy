$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# define multiple deployments
set :stages, %w(production staging)
set :default_stage, "staging"

require 'capistrano/ext/multistage'
require 'rvm/capistrano'
require 'bundler/capistrano'

# configuration common to all deployment environments

set :application, "cappy.com"                         # the name of your website - should also be the name of the directory

# roles

role :web, "#{application}"
role :app, "#{application}"
role :db,  "#{application}"

# git

set :scm, :git
set :repository,  "git@github.com:hinosx/cappy.git"
set :branch, "master"
set :deploy_via, :remote_cache                        # fetches from local git repo on the server rather then clone repo on each deploy

# server env

set :user, "deploy"                                   # the name of the deployment user-account on the server
set :deploy_to, "/var/www/sites/#{application}"       # the path to your new deployment directory on the server - by default, the name of the application (e.g. "/var/www/sites/example.com")
set :keep_releases, 3
set :use_sudo, false
set :rvm_bin_path, '/usr/local/rvm/bin'               # newer version of rvm live in /usr/local/rvm

# ssh connection

default_run_options[:pty] = true                      # Prompts for key passphrase, needed when using a deploy key pair instead of agent forwarding
# set :ssh_options, { :forward_agent => true }        # use your private keys to authenticate to server and github

# deployment process

after "deploy:update", "passenger:setup_symlinks"

# tasks

namespace :passenger do
  desc "Creates a symlink for the database.yml file"
  task :setup_symlinks, :roles => :app do
    puts "\n\n=== Setting up symbolic links ===\n\n"
    run "ln -s #{deploy_to}/#{shared_dir}/config/database.yml #{current_path}/config/database.yml"
  end
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
