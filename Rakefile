task :default => [:coffee]

task :coffee do
  sh "coffee -m -o public/js -c coffee/"
end

task :serve do
  sh "shotgun app.rb"
end

task :deploy do
  sh "rsync --checksum --progress -ave ssh public/* views/* app.rb config.ru sphynx@horna.org.ua:/srv/horna.org.ua/loa-board"
end



