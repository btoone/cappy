# the name of your website - should also be the name of the directory
set :application, "cappy.com"

set :repository,  "git@github.com/hinosx/cappy.git"
set :branch, "master"

# the name of the deployment user-account on the server
set :user, "deploy"

# the path to your new deployment directory on the server
# by default, the name of the application (e.g. "/var/www/sites/example.com")
set :deploy_to, "/var/www/sites/#{application}"

set :scm, :git
set :keep_releases, 3
set :use_sudo, false

# Roles
role :web, "#{application}"
role :app, "#{application}"
role :db,  "#{application}"

# Deployment process
after "deploy:update", "passenger:setup_symlinks"
after "deploy:migrate"

# Custom deployment tasks
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
