object @deployment

extends "foreman_deployments/api/v2/deployments/main"

node :configuration do
  @deployment.parsed_stack.to_hash
end

node :errors do
  @validation_result.messages
end
