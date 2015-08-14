object @stack

extends "foreman_deployments/api/v2/stacks/main"

node :definition do
  @parsed_stack.to_hash
end
