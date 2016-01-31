$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'dockertags/version'

Gem::Specification.new do |s|
  s.name        = 'docker-tags'
  s.version     = DockerTags::VERSION
  s.authors     = ['Jasper Lievisse Adriaanse'],
  s.email       = ['jasper@humppa.nl']
  s.homepage    = "https://github.com/jasperla/docker-tags"
  s.summary     = 'Track tags of Docker images.'
  s.description = 'Track and report tags of followed Docker images.'

  s.required_ruby_version = '>= 1.9.3'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'commander', '~> 4.3'
  s.add_runtime_dependency 'faraday'
  s.add_runtime_dependency 'sqlite3'

  s.add_development_dependency 'bundler', '~> 1.3'
end
