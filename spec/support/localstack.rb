# frozen_string_literal: true

require 'open3'
require 'pathname'

require 'aws-sdk-s3'

module Localstack
  def up
    env = {
      'TMPDIR' => Pathname(ENV.fetch('TMPDIR', '/tmp')).realpath.to_s,
      'SERVICES' => 's3'
    }
    _in, out, _waiter = Open3.popen2(env, 'docker-compose', 'up')
    out.find {|line| line =~ /Ready/ }
  end
  module_function :up

  def down
    pid = spawn('docker-compose', 'down')
    Process.wait(pid)
  end
  module_function :down

  class Bucket
    def initialize(name)
      @name = name
      @s3 = Aws::S3::Resource.new(endpoint: 'http://localhost:4572', force_path_style: true)
    end

    def setup
      bucket = prepare_clean_bucket

      local_files.each do |file|
        key = file.relative_path_from(local_path).to_s
        bucket.put_object(key: key, body: file.read)
      end
    end

    private

    def prepare_clean_bucket
      @s3.bucket(@name).tap do |bucket|
        bucket.create unless bucket.exists?
        bucket.objects.each(&:delete)
      end
    end

    def local_files
      local_path.glob('**/*').select(&:file?)
    end

    def local_path
      fixture_path + 'buckets' + @name
    end

    def fixture_path
      Pathname(File.expand_path('../fixtures', __dir__))
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    unless ENV.key?('CIRCLECI')
      puts 'Booting localstack'
      Localstack.up
    end
  end

  config.after(:suite) do
    unless ENV.key?('CIRCLECI')
      puts 'Shutting down localstack'
      Localstack.down
    end
  end
end
