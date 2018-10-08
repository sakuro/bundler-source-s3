# frozen_string_literal: true

require 'bundler/plugin/api'
require 'bundler/source'

require 'bundler/source/s3/version'
require 'bundler/source/s3/fetcher'

require 'aws-sdk-s3'

module Bundler
  class Source
    class S3
      Bundler::Plugin::API.source('s3', self)
    end
  end
end
