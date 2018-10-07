# frozen_string_literal: true

require 'bundler/source/s3'

Bundler::Plugin::API.source('s3', Bundler::Source::S3)
