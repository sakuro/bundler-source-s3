# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'rubocop/rake_task'

Dir.glob('./tasks/*.rake').each(&method(:load))

RSpec::Core::RakeTask.new(:spec)

task default: :spec

YARD::Rake::YardocTask.new(:yard)

RuboCop::RakeTask.new(:rubocop)
