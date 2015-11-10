require File.expand_path('../lib/foreman_deployments/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_deployments'
  s.version     = ForemanDeployments::VERSION
  s.date        = Date.today.to_s
  s.authors     = ['Foreman Deployments team']
  s.email       = ['foreman-dev@googlegroups.com']
  s.homepage    = 'https://github.com/theforeman/foreman_deployments'
  s.summary     = 'A plugin adding Multi-Host Deployment support into the Foreman.'
  s.description = 'A plugin adding Multi-Host Deployment support into the Foreman.'

  s.files      = Dir['{app,config,db,doc,lib,locale}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'foreman-tasks', "~> 0.7.3"
  s.add_dependency 'safe_yaml', "~> 1.0.0"

  s.add_development_dependency 'rubocop'
end
