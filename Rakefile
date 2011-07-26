require 'bundler'

# copied from RSpec :-p
require 'rspec'
require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t| 
  t.rspec_path = 'rspec'
  t.rspec_opts = %w[--color]
  t.verbose = false
end

desc "Run specs and (legacy) test"
# there's also some found interwebs code in here which uses test/unit instead of rspec
task :tdd => :spec do
  system "ruby test/test_array_intersection.rb"
end

