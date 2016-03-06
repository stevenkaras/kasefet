# Kasefet

Kasefet is a password wallet built around flat files.

NOTE: This version of kasefet is not meant to be highly secure. It is a reference implementation

## Current Status

Kasefet is currently a work in progress. This is the todo list for version 1.0, and is based entirely on my own requirements:

 - [x] Flat file wallet
 - [x] SSL encrypted wallet
 - [ ] support for multiple wallets
 - [ ] editor integration
 - [ ] clipboard integration (Mac)
 - [ ] autotype (Mac)
 - [ ] clipboard integration (Ubuntu)
 - [ ] autotype (Ubuntu)

## Installation

```
$ gem install kasefet
```

## Usage

```
# Create a simple record of username:password under the name "Gmail"
$ kasefet add Gmail example@example.com:sekret

# Open the record for Facebook in an editor
$ kasefet edit Facebook

# Print the contents of the Gmail credential file to STDOUT
$ kasefet show Gmail
```

```
# Create a new wallet (default format is encrypted)
$ kasefet new --format=plain ~/my-new-wallet

# Add another wallet to search through
$ kasefet addwallet ~/my-new-wallet
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec kasefet` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stevenkaras/kasefet.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
