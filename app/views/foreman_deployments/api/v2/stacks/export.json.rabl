object @stack

extends 'foreman_deployments/api/v2/stacks/main'

child :resources => :resources do
  extends "foreman_deployments/api/v2/resources/export"
end

