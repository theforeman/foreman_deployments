object @deployment

extends 'foreman_deployments/api/v2/deployments/base'

attributes :created_at, :updated_at

child stack: :stack do
  extends "foreman_deployments/api/v2/stacks/base"
end
