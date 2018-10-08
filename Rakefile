# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

Dir.glob('./tasks/*.rake').each(&method(:load))

$logger = Logger.new(STDOUT)

RSpec::Core::RakeTask.new(:spec)

task default: :spec

YARD::Rake::YardocTask.new(:yard)
