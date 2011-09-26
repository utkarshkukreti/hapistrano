# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hapistrano/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Utkarsh Kukreti"]
  gem.email         = ["utkarshkukreti@gmail.com"]
  gem.description   = %q{Heroku like easy deployment using Capistrano}
  gem.summary       = %q{Heroku like easy deployment using Capistrano}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "hapistrano"
  gem.require_paths = ["lib"]
  gem.version       = Hapistrano::VERSION

  gem.add_dependency 'net-ssh', "~> 2.2.1"
  gem.add_dependency 'highline'
end
