task :default => [:coffee]

desc "Compiles CoffeeScript code"
task :coffee do
  sh "coffee -m -o public/js -c coffee/"
end

desc "Runs the server locally"
task :serve do
  sh "shotgun app.rb"
end

desc "Deploys essential files to remote server"
task :deploy do
  sh "rsync --checksum --progress -ave ssh public views app.rb config.ru sphynx@horna.org.ua:/srv/horna.org.ua/loa-board"
end
