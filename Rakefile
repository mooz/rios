# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name        = "rios"
  gem.homepage    = "https://github.com/mooz/rios"
  gem.license     = "MIT"
  gem.email       = "stillpedant@gmail.com"
  gem.authors     = ["mooz"]
  gem.summary     = %Q{A proxy framework for command line interfaces}
  gem.description = %Q{Rios is a proxy framework which works as a proxy
 for command line applications and allows developer to hook input/output
 of the applications in a blazingly simple way.}
  # native extension
  gem.extensions  = FileList['ext/**/extconf.rb']
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rios #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :test
