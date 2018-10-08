# frozen_string_literal: true

require 'pathname'
require 'tmpdir'

RSpec.shared_context 'with tmpdir' do
  let(:tmpdir) { Pathname(Dir.mktmpdir) }

  after do
    tmpdir.rmtree if tmpdir.exist?
  end
end

RSpec.configure do |config|
  config.include_context 'with tmpdir', :tmpdir
end
