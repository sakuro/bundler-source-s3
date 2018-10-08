# frozen_string_literal: true

require 'pathname'
require 'aws-sdk-s3'

namespace :localstack do
  task :up do
    env = {
      'TMPDIR' => Pathname(ENV.fetch('TMPDIR', '/tmp/localstack')).realpath.to_s,
      'SERVICES' => 's3'
    }
    pid = spawn(env, 'docker-compose', 'up')
    Process.detach(pid)
  end

  task :down do
    pid = spawn('docker-compose', 'down')
    Process.wait(pid)
  end

  task prepare: %w[prepare:s3]

  namespace :prepare do
    task :s3 do
      s3 = Aws::S3::Resource.new(endpoint: 'http://localhost:4572', force_path_style: true)
      #s3.buckets.each(&:delete!)

      fixture_root = Pathname(File.expand_path('../spec/fixtures', __dir__))
      local_buckets_root = fixture_root + 'buckets'
      local_buckets = local_buckets_root.children
      local_buckets.each do |local_bucket|
        bucket_name = local_bucket.relative_path_from(local_buckets_root).to_s
        bucket = s3.create_bucket(bucket: bucket_name)
        $logger.debug('CreaateBucket: %s' % bucket_name)
        files = local_bucket.glob('**/*').select(&:file?)
        files.each do |file|
          key = file.relative_path_from(local_bucket).to_s
          bucket.put_object(key: key, body: file.read)
          $logger.debug('PutObject: %s/%s' % [bucket_name, key])
        end
      end
    end
  end
end
