# frozen_string_literal: true

require 'bundler/source/s3/fetcher'

RSpec.describe Bundler::Source::S3::Fetcher, s3: true do
  subject(:fetcher) { Bundler::Source::S3::Fetcher.new(bucket: bucket) }

  let(:bucket_name) { 'fetcher' }

  before do
    Localstack::Bucket.new('fetcher').setup
  end

  describe '#initialize' do
    context 'when bucket of given name exists' do
      it { expect { fetcher }.not_to raise_error }
    end

    context 'when bucket of given name does not exist' do
      let(:bucket_name) { 'missing_bucket' }

      it { expect { fetcher }.to raise_error(Bundler::Source::S3::MissingBucket, bucket_name) }
    end
  end

  describe '#list' do
    context 'without prefix' do
      it 'returns all object keys' do
        expect(fetcher.list).to match_array(['aaa/111', 'aaa/222', 'bbb/111'])
      end
    end

    context 'with prefix' do
      it 'returns only matching object keys' do
        expect(fetcher.list(prefix: 'aaa/')).to match_array(['aaa/111', 'aaa/222'])
      end
    end
  end

  describe '#fetch', tmpdir: true do
    let(:key) { 'aaa/111' }
    let(:path) { tmpdir + key }

    context 'when local file does not exist' do
      before do
        tmpdir.children.each(&:rmtree)
      end

      it 'creates a local file' do
        expect { fetcher.fetch(key, root: tmpdir) }.to change(path, :exist?).from(false).to(true)
      end
      it 'writes the content of the object into the local file' do
        fetcher.fetch(key, root: tmpdir)
        expect(path.read).to eq("content of aaa/111\n")
      end
    end

    context 'when local file exists and have different contents' do
      before do
        path.dirname.mkpath unless path.dirname.exist?
        path.write("old content\n")
      end

      it 'does not remove the local file' do
        expect { fetcher.fetch(key, root: tmpdir) }.not_to change(path, :exist?).from(true)
      end

      it 'writes the content of the object into the local file' do
        expect {
          fetcher.fetch(key, root: tmpdir)
        }.to change(path, :read).from("old content\n").to("content of aaa/111\n")
      end
    end

    context 'when local file exists and have same contents' do
      before do
        path.dirname.mkpath unless path.dirname.exist?
        path.write("content of aaa/111\n")
      end

      it 'does not remove the local file' do
        expect { fetcher.fetch(key, root: tmpdir) }.not_to change(path, :exist?).from(true)
      end

      it 'does not modify the local file' do
        expect { fetcher.fetch(key, root: tmpdir) }.not_to change(path, :mtime)
      end
    end
  end
end
