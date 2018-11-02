# frozen_string_literal: true

require 'open3'
require 'pathname'

require 'aws-sdk-s3'
require 'pry-byebug'

module Localstack
  def up
    env = {
      'TMPDIR' => Pathname(ENV.fetch('TMPDIR', '/tmp/localstack')).realpath.to_s,
      'SERVICES' => 's3'
    }
    _in, out, _waiter = Open3.popen2(env, 'docker-compose', 'up')
    out.find {|line| line =~ /Ready/ }
  end

  def down
    pid = spawn('docker-compose', 'down')
    Process.wait(pid)
  end

  extend self

  module S3
    def prepare_bucket(bucket_name)
      s3 = Aws::S3::Resource.new(endpoint: 'http://localhost:4572', force_path_style: true)

      bucket = s3.bucket(bucket_name)
      bucket.create unless bucket.exists?
      bucket.objects.each(&:delete)

      fixture_root = Pathname(File.expand_path('../fixtures', __dir__))
      local_bucket = fixture_root + 'buckets' + bucket_name

      files = local_bucket.glob('**/*').select(&:file?)

      files.each do |file|
        key = file.relative_path_from(local_bucket).to_s
        bucket.put_object(key: key, body: file.read)
      end
    end

    extend self
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    puts 'Booting localstack'
    Localstack.up
  end

  config.after(:suite) do
    puts 'Shutting down localstack'
    Localstack.down
  end
end
