require "rake/testtask"

task :default => [:test] # required by travis

Rake::TestTask.new(:test) do |test|
	test.pattern = "test/*_test.rb"
	test.verbose = true
end
