object @stack

extends 'foreman_deployments/api/v2/stacks/main'

node do |stack|
  partial("api/v2/taxonomies/children_nodes", :object => stack)
end
