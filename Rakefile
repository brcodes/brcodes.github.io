require 'html-proofer'

desc 'Serve site locally with Jekyll live reload enabled'
task :serve do
  # Keep LiveReload on a non-default port to avoid conflicts with editor extensions.
  sh 'bundle exec jekyll serve --livereload --livereload-port 35730 --host 127.0.0.1 --port 4000'
end

task :test do
  sh "bundle exec jekyll build"
  options = { :assume_extension => true, :only_4xx => true, :allow_hash_href => true}
  HTMLProofer.check_directory("./_site", options).run
end
