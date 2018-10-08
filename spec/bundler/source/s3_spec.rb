# frozen_string_literal: true

require 'bundler/source/s3'
require 'bundler/source/s3/fetcher'

RSpec.describe Bundler::Source::S3, s3: true do
  subject(:plugin) { Bundler::Source::S3.new('uri' => bucket_name, 'fetcher' => fetcher) }

  let(:bucket_name) { 'source' }
  let(:fetcher) { Bundler::Source::S3::Fetcher.new(bucket: bucket) }

  describe '#uri' do
    it 'is "source"' do
      expect(plugin.uri).to eq('source')
    end
  end

  describe '#bundler_plugin_api_source?' do
    it 'is true' do
      expect(plugin.send(:bundler_plugin_api_source?)).to be true # rubocop:disable Style/Send
    end
  end

  describe '#fetch_gemspec_files', tmpdir: true do
    before do
      allow(plugin.send(:api)).to receive(:cache_dir).and_return(tmpdir) # rubocop:disable Style/Send
    end

    it 'lists gemspec paths copied to local cache' do # rubocop:disable RSpec/ExampleLength
      expect(plugin.fetch_gemspec_files).to match_array(
        %w[
          test-dep-1.0.0.gemspec
          test-dep-2.0.0.gemspec
          test-one-0.1.0.gemspec
          test-one-1.0.0.gemspec
          test-one-1.0.1.gemspec
          test-one-1.1.0.gemspec
          test-one-2.0.0.gemspec
        ].map {|name| (tmpdir + 's3' + 'specifications' + name).to_s }
      )
    end

    it 'actually fetches gemspec files' do
      expect(plugin.fetch_gemspec_files.map(&method(:Pathname))).to all(be_exist)
    end
  end

  it 'has a version number' do
    expect(Bundler::Source::S3::VERSION).not_to be nil
  end
end
