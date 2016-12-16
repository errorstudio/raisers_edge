# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'raisers_edge/version'

Gem::Specification.new do |spec|
  spec.name          = "raisers_edge"
  spec.version       = RaisersEdge::VERSION
  spec.authors       = ["Ed Jones", "Paul Hendrick"]
  spec.email         = ["ed@error.agency", "paul@error.agency"]

  spec.summary       = %q{A library to access the Blackbaud Raiser's Edge NXT API}
  spec.description   = %q{A library to access the Blackbaud Raiser's Edge NXT API. The API docs are available at https://developer.sky.blackbaud.com/}
  spec.homepage      = "https://github.com/errorstudio/raisers_edge"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "her","~>0.8"
  spec.add_dependency "require_all", "~> 1.3"
  spec.add_dependency 'oauth2', '>= 1'
end
