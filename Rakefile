require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cassandra-model"
    gem.summary = %Q{Minimal models for Cassandra.}
    gem.description = %Q{Cassandra-model allows you to map ColumnFamily/SuperColumnFamily in Cassandra to Ruby objects. It was designed to be fast and simple.}
    gem.email = "tienlx /at/ gmail /dot/ com"
    gem.homepage = "http://github.com/tienle/cassandra-model"
    gem.authors = ["Tien Le"]
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_development_dependency "cassandra", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cassandra-model #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


CASSANDRA_HOME = ENV["CASSANDRA_HOME"] || "#{ENV["HOME"]}/apache-cassandra-0.6.0"
CASSANDRA_PID  = ENV["CASSANDRA_PID"] || "/tmp/cassandra.pid".freeze

cassandra_env = ""
cassandra_env << "CASSANDRA_INCLUDE=#{File.expand_path(Dir.pwd)}/test/config/cassandra.in.sh "
cassandra_env << "CASSANDRA_HOME=#{CASSANDRA_HOME} "
cassandra_env << "CASSANDRA_CONF=#{File.expand_path(Dir.pwd)}/test/config"

namespace :cassandra do
  desc "Start cassandra"
  task :start do
    Dir.chdir(CASSANDRA_HOME) do
      sh("env #{cassandra_env} bin/cassandra -f -p #{CASSANDRA_PID}")
    end
  end

  desc "Stop cassandra"
  task :stop do
    system "kill -9 `cat #{CASSANDRA_PID}`"
  end

  desc "Restart cassandra"
  task :restart => [:stop, :start]

  desc "Clear test data"
  task :clear_test_data do
    unless defined?(CassandraModel)
      $: << 'test'
      require 'test_helper'
    end
    CassandraModel::Base.establish_connection('CassandraModel').clear_keyspace!
  end
end

