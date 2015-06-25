require File.expand_path('../lib/foreman_deployments/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_deployments'
  s.version     = ForemanDeployments::VERSION
  s.date        = Date.today.to_s
  s.author     = 'ForemanDeployments team'
  s.email       = 'foreman_deployments@example.com'
  s.homepage    = 'https://github.com/theforeman/foreman_deployments'
  s.summary     = 'Foreman Deployments'
  s.description = 'Foreman Deployments'

  s.files      = Dir['{app,config,db,lib}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'foreman-tasks'
end
