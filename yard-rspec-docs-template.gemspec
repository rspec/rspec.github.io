# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "yard-rspec-docs-template"
  spec.version       = "0.0.1"
  spec.authors       = ["Jon Rowe"]
  spec.email         = ["hello@jonrowe.co.uk"]
  spec.summary       = %q{Skin for RSpec documentation in YARD}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/rspec/rspec.github.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z lib`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_dependency "yard"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
