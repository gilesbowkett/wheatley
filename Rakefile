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
