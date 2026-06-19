require 'html-proofer'
require 'socket'

def first_available_port(host, ports)
  ports.find do |port|
    begin
      server = TCPServer.new(host, port)
      server.close
      true
    rescue Errno::EADDRINUSE, Errno::EACCES
      false
    end
  end
end

desc 'Serve site locally with Jekyll live reload enabled'
task :serve do
  host = '127.0.0.1'

  site_port = first_available_port(host, [4000, 4001, 4002, 4003, 4004, 4005])
  raise 'No available site port found in 4000-4005' unless site_port

  # Keep LiveReload on a non-default port to avoid conflicts with editor extensions.
  # If that port is busy, choose the next available port in a small fallback range.
  livereload_port = first_available_port(host, [35730, 35731, 35732, 35733])

  raise 'No available livereload port found in 35730-35733' unless livereload_port

  puts "Serving on http://#{host}:#{site_port} (LiveReload: #{livereload_port})"
  sh "bundle exec jekyll serve --livereload --livereload-port #{livereload_port} --host #{host} --port #{site_port}"
end

desc 'Build site output into _site'
task :'test:build' do
  sh 'bundle exec jekyll build'
end

desc 'Run HTML regression tests against generated site output'
task :'test:site' => :'test:build' do
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
