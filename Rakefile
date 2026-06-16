require 'html-proofer'
require 'socket'

desc 'Serve site locally with Jekyll live reload enabled'
task :serve do
  # Keep LiveReload on a non-default port to avoid conflicts with editor extensions.
  # If that port is busy, choose the next available port in a small fallback range.
  livereload_port = [35730, 35731, 35732, 35733].find do |port|
    begin
      server = TCPServer.new('127.0.0.1', port)
      server.close
      true
    rescue Errno::EADDRINUSE, Errno::EACCES
      false
    end
  end

  raise 'No available livereload port found in 35730-35733' unless livereload_port

  sh "bundle exec jekyll serve --livereload --livereload-port #{livereload_port} --host 127.0.0.1 --port 4000"
end

desc 'Build site output into _site'
task :'test:build' do
  sh 'bundle exec jekyll build'
end

desc 'Run HTML regression tests against generated site output'
task :'test:site' do
  sh 'bundle exec ruby -Itest test/site_regression_test.rb'
end

desc 'Run internal link and script checks on generated HTML'
task :'test:links' => :'test:build' do
  options = {
    :assume_extension => true,
    :only_4xx => true,
    :allow_hash_href => true,
    :disable_external => true
  }
  HTMLProofer.check_directory("./_site", options).run
end

desc 'Run full test suite (build + regression + link checks)'
task :test => [:'test:build', :'test:site', :'test:links']
