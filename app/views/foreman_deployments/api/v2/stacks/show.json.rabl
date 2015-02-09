object @stack

extends 'foreman_deployments/api/v2/stacks/main'

node do |stack|
  partial("api/v2/taxonomies/children_nodes", :object => stack)
end

child resources: :resources do
  extends 'foreman_deployments/api/v2/resources/main'
end

node :configurable_resources do |stack|
  stack.configurable_resources.values.flatten.map { |r| partial 'foreman_deployments/api/v2/resources/main', object: r }
end
