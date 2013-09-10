# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "unicorn-ctl"
  spec.version       = "0.0.1"
  spec.authors       = [ "Oleksiy Kovyrin" ]
  spec.email         = [ "alexey@kovyrin.net" ]
  spec.description   = %q{A script to control unicorn instances.}
  spec.summary       = %q{Start/stop/restart/upgrade unicorn instances reliably.}
  spec.homepage      = "https://github.com/swiftype/unicorn-ctl"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "httparty"
end
