# frozen_string_literal: true

require 'aws-sdk-s3'

RSpec.shared_context 'with Localstack/S3' do
  let(:bucket) { Aws::S3::Bucket.new(name: bucket_name, client: client) }
  let(:client) { Aws::S3::Client.new(endpoint: 'http://localhost:4572', force_path_style: true) }
end

RSpec.configure do |config|
  config.include_context 'with Localstack/S3', :s3
end
