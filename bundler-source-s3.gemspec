
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bundler/source/s3/version'

Gem::Specification.new do |spec|
  spec.name          = 'bundler-source-s3'
  spec.version       = Bundler::Source::S3::VERSION
  spec.authors       = ['OZAWA Sakuro']
  spec.email         = ['sakuro@2238.club']

  spec.summary       = %q{S3 source type for bundler}
  spec.description   = %q{This bundler plugin adds a source type S3 which enables fetching/installing gems from AWS S3.}
  spec.homepage      = 'https://github.com/sakuro/bundler-source-s3'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/sakuro/bundler-source-s3.git'
    spec.metadata['changelog_uri'] = 'https://github.com/sakuro/bundler-source-s3/blob/master/README.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-s3', '~>1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.59'
  spec.add_development_dependency 'rubocop-rspec'
end
