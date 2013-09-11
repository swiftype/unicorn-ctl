# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "unicorn-ctl"
  spec.version       = "0.0.5"
  spec.authors       = [ "Oleksiy Kovyrin" ]
  spec.email         = [ "alexey@kovyrin.net" ]
  spec.description   = %q{A script to control unicorn instances.}
  spec.summary       = %q{Start/stop/restart/upgrade unicorn instances reliably.}
  spec.homepage      = "https://github.com/swiftype/unicorn-ctl"
  spec.license       = "MIT"

  spec.files         = Dir[ "{lib}/**/*.rb", "bin/*", "LICENSE.txt" ]
  spec.executables   = %w[ unicornctl ]

  spec.add_dependency "httparty"
  spec.add_dependency "bundler"
end
