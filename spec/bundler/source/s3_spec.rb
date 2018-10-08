# frozen_string_literal: true

require 'bundler/source/s3'
require 'bundler/source/s3/fetcher'

RSpec.describe Bundler::Source::S3 do
  subject(:plugin) { Bundler::Source::S3.new('uri' => bucket_name, 'fetcher' => fetcher) }

  let(:bucket_name) { 'source' }
  let(:client) { Aws::S3::Client.new(endpoint: 'http://localhost:4572', force_path_style: true) }
  let(:bucket) { Aws::S3::Bucket.new(name: bucket_name, client: client) }
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

  describe '#fetch_gemspec_files' do
    let(:cache_dir) { Pathname(Dir.mktmpdir) }

    before do
      allow(plugin.send(:api)).to receive(:cache_dir).and_return(cache_dir) # rubocop:disable Style/Send
    end

    after do
      cache_dir.rmtree if cache_dir.exist?
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
        ].map {|name| (cache_dir + 's3' + 'specification' + name).to_s }
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
