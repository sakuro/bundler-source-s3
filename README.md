# Bundler::Source::S3

Bundler::Source::S3 is a Bundler's source plugin which enables installing gems from AWS S3.

## :warning: Warning :warning:

* The development has just started and is still missing major functionalities (ex. installation of gems).
* This gem is unofficial.

## Installation

Install this plugin by running

```
bundle plugin install bundler-source-s3
```

Or add this line to your application's Gemfile:

```
plugin 'bundler-source-s3'
```

And then execute:

```
$ bundle
```

## Usage

In your Gemfile, put

```
source 'YOUR_BUCKET_NAME', type: 's3' do
  gem 'gem-on-bucket'
end
```

## Development

After checking out the repo:

1. Set environment variables to use AWS S3. (ex. `AWS_PROFILE` and `AWS_REGION`)
2. Run <kbd>bin/setup</kbd> to install dependencies.
3. Run <kbd>bundle exec rake localstack:up</kbd> to boot the AWS stack for testing.
4. After the stack has booted, run <kbd>bundle exec rake localstack:prepare</kbd> to upload contents of S3 bucket for testing.
5. Run <kbd>bundle exedc rake</kbd> to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sakuro/bbundler-source-s3.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
