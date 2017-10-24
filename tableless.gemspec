# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tableless/version'

Gem::Specification.new do |spec|
  spec.name          = "tableless"
  spec.version       = Tableless::VERSION
  spec.authors       = ["Peter Schrammel"]
  spec.email         = ["peter.schrammel@experteer.com"]
  spec.description   = %q{ActiveModel + belongs_to associations}
  spec.summary       = %q{Even with ActiveModel you might need this}
  spec.homepage      = "http://github.com/experteer/tableless"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec","~> 2.3"
  spec.add_development_dependency "sqlite3","~> 1.3"

  spec.add_dependency "activerecord",">= 5.1.0"
  spec.add_dependency "activesupport",">= 5.1.0"
end
