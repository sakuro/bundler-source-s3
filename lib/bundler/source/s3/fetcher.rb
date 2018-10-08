# frozen_string_literal: true

require 'aws-sdk-s3'
require 'bundler/source/s3/errors'

module Bundler
  class Source
    class S3
      # A convenient class for fetching objects from S3 buckets
      class Fetcher
        # @param [String] bucket Name of the bucket
        def initialize(bucket:)
          raise MissingBucket, bucket.name unless bucket.exists?

          @bucket = bucket
        end

        attr_reader :bucket
        private :bucket

        # List keys of objects stored in the bucket
        # @param [String] prefix Prefix to match
        # @return [Array<String>] list of keys
        def list(prefix: nil)
          bucket.objects(prefix: prefix).map(&:key)
        end

        # Fetch an object from the bucket and store it under given directory
        # @param [String] key The key of the object to fetch
        # @param [Pathname] root The destination where fetched object is stored
        # @return [Pathname] A Pathname object which represents the fetched file
        def fetch(key, root:)
          (root + key).tap do |path|
            break path if path.exist? && same?(key, path)

            SharedHelpers.filesystem_access(path.dirname) do |dir|
              dir.mkpath unless dir.exist?
            end
            SharedHelpers.filesystem_access(path) do
              remote_object(key).get(response_target: path)
            end
          end
        end

        private

        def same?(key, path)
          remote_digest(key) == local_digest(path)
        end

        def remote_digest(key)
          remote_object(key).etag.delete(?")
        end

        def remote_object(key)
          bucket.object(key)
        end

        def local_digest(path)
          SharedHelpers.filesystem_access(path) do
            SharedHelpers.digest(:MD5).hexdigest(path.binread)
          end
        end
      end
    end
  end
end
