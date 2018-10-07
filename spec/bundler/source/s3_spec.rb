# frozen_string_literal: true

RSpec.describe Bundler::Source::S3 do
  it 'has a version number' do
    expect(Bundler::Source::S3::VERSION).not_to be nil
  end
end
