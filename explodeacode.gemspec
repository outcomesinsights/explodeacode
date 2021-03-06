# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'explodeacode/version'

Gem::Specification.new do |spec|
  spec.name          = "explodeacode"
  spec.version       = Explodeacode::VERSION
  spec.authors       = ["Ryan Duryea"]
  spec.email         = ["aguynamedryan@gmail.com"]
  spec.summary       = %q{Blow up your codes!}
  spec.description   = %q{Some more stuff}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rb-readline"
  spec.add_dependency "thor"
  spec.add_dependency "facets"
end
