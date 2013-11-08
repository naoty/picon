# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'picon/version'

Gem::Specification.new do |spec|
  spec.name          = "picon"
  spec.version       = Picon::VERSION
  spec.authors       = ["Naoto Kaneko"]
  spec.email         = ["naoty.k@gmail.com"]
  spec.description   = %q{This gem generates identicons for iOS apps. It is helpful for developers who cannot create icons with tools such as Adobe Illustrator. Apps under development are usually have the save default icon, and so cannot be tell apart at a glance. However, apps with identicons generated by this gem are can be identified by their icons.}
  spec.summary       = %q{Generator of identicon for iOS apps}
  spec.homepage      = "https://github.com/naoty/picon"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
