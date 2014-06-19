# encoding: utf-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'unicorn_ctl/version'

Gem::Specification.new do |spec|
  spec.name          = "unicorn-ctl"
  spec.version       = UnicornCtl::Version::STRING
  spec.authors       = [ "Oleksiy Kovyrin" ]
  spec.email         = [ "alexey@kovyrin.net" ]
  spec.description   = %q{A script to control unicorn instances.}
  spec.summary       = %q{Start/stop/restart/upgrade unicorn instances reliably.}
  spec.homepage      = "https://github.com/swiftype/unicorn-ctl"
  spec.license       = "MIT"

  spec.files         = Dir[ "{lib}/**/*.rb", "bin/*", "*.txt", "*.md" ]
  spec.executables   = %w[ unicornctl ]

  spec.add_dependency "httparty"
  spec.add_dependency "bundler"
end
