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
        SharedHelpers.filesystem_access(gemspec_cache_dir, false) do
          gemspec_cache_dir.glob('*.gemspec').map(&:to_s)
        end
      end

      # See Bundler::Plugin::API::Source
      # @param [Gem::Specification] spec Gem's specificatino
      # @param [Hash] options Install options
      # @return [String] post installation message (if any)
      def install(spec, options)
        fetch(gem_key(spec.full_name)) do |gem_path|
          installer = Gem::Installer.at(gem_path.to_s, options)
          installer.install
          spec.post_install_message
        end
      end

      def dependency_names_to_double_check # rubocop:disable Style/DocumentationMethod
        []
      end

      private

      def create_fetcher
        bucket = create_bucket
        Bundler::Source::S3::Fetcher.new(bucket: bucket)
      end

      def create_bucket
        Aws::S3::Bucket.new(name: @uri)
      end

      def fetch(key)
        tmp = api.tmp
        path = fetcher.fetch(key, root: tmp)
        yield(path)
      ensure
        tmp.rmtree if tmp.exist?
      end

      def load_specs
        fetch(specs_gz_key) do |path|
          SharedHelpers.filesystem_access(path, false) do
            api.load_marshal(Zlib.gunzip(path.binread))
          end
        end
      end

      def specs_gz_key
        'specs.%s.gz' % Gem.marshal_version
      end

      def gemspec_cache_dir
        api.cache_dir + 's3' + 'specifications'
      end

      def load_gemspec(full_name)
        fetch(gemspec_rz_key(full_name)) do |path|
          SharedHelpers.filesystem_access(path, false) do
            api.load_marshal(Zlib.inflate(path.binread))
          end
        end
      end

      def cache_gemspec(gemspec)
        path = gemspec_cache_dir + (gemspec.full_name + '.gemspec')
        SharedHelpers.filesystem_access(path.dirname) do |dir|
          dir.mkpath unless dir.exist?
        end
        SharedHelpers.filesystem_access(path) do
          path.write(gemspec.to_ruby)
        end
      end

      def gemspec_rz_key(full_name)
        'quick/Marshal.%s/%s.gemspec.rz' % [Gem.marshal_version, full_name]
      end

      def gem_key(full_name)
        'gems/%s.gem' % full_name
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
