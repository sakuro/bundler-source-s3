# frozen_string_literal: true

require 'zlib'

require 'bundler/plugin/api'
require 'bundler/source'

require 'aws-sdk-s3'

require 'bundler/source/s3/version'
require 'bundler/source/s3/fetcher'

module Bundler
  class Source
    class S3
      Bundler::Plugin::API.source('s3', self)

      # Initializes an S3 source
      # @param [Hash<String,Object>] options Options for this source
      # @option options [Bundler::Source::S3::Fetcher] fetcher Explicit Fetcher object
      def initialize(options)
        super
        @fetcher = options['fetcher'] || create_fetcher
      end

      attr_reader :fetcher
      private :fetcher

      # See Bundler::Plugin::API::Source
      # @return [Array<String>] Full paths of gemspec files
      def fetch_gemspec_files
        specs = load_specs
        specs.each do |spec|
          full_name = '%s-%s' % spec
          gemspec = load_gemspec(full_name)
          cache_gemspec(gemspec)
        end
        gemspec_cache_dir.glob('*.gemspec').map(&:to_s)
      end

      private

      def create_fetcher
        bucket = create_bucket
        Bundler::Source::S3::Fetcher.new(bucket: bucket)
      end

      def create_bucket
        Aws::S3::Bucket.new(name: @uri)
      end

      def load_specs
        specs_gz = fetcher.fetch('specs.%s.gz' % Gem.marshal_version, root: api.tmp)
        Marshal.load(Zlib.gunzip(specs_gz.binread)) # rubocop:disable Security/MarshalLoad
      end

      def gemspec_cache_dir
        api.cache_dir + 's3' + 'specification'
      end

      def load_gemspec(full_name)
        path = fetch_gemspec_rz(full_name)
        Marshal.load(Zlib.inflate(path.binread)) # rubocop:disable Security/MarshalLoad
      end

      def cache_gemspec(gemspec)
        path = gemspec_cache_dir + (gemspec.full_name + '.gemspec')
        path.dirname.mkpath unless path.dirname.exist?
        path.write(gemspec.to_ruby)
      end

      def fetch_gemspec_rz(full_name)
        gemspec_rz_key = 'quick/Marshal.%s/%s.gemspec.rz' % [Gem.marshal_version, full_name]
        fetcher.fetch(gemspec_rz_key, root: api.tmp)
      end

      def api
        @api ||= create_api
      end

      def create_api
        Bundler::Plugin::API.new
      end
    end
  end
end
