# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kasefet/version"

require "rbconfig" # for platform data

Gem::Specification.new do |spec|
  spec.name          = "kasefet"
  spec.version       = Kasefet::VERSION
  spec.authors       = ["Steven Karas"]
  spec.email         = ["steven.karas@gmail.com"]

  spec.summary       = %q{flat file-oriented password wallet}
  spec.description   = %q{Kasefet is a password wallet built around flat files}
  spec.homepage      = "https://github.com/stevenkaras/kasefet"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thunder", "~> 0.7"
  spec.add_runtime_dependency "clipboard", "~> 1.0"

  case RbConfig::CONFIG['host_os']
  when /windows/
    spec.add_runtime_dependency "ffi"
  end

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
