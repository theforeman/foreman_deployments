object @deployment

extends 'foreman_deployments/api/v2/deployments/main'

node do |deployment|
  partial("api/v2/taxonomies/children_nodes", :object => deployment)
end

attribute :configuration_phase

node :configurable_resources do |deployment|
  deployment.configurable_resources.values.flatten.map do |resource|
    partial 'foreman_deployments/api/v2/resources/main', object: resource
  end
end

node :configured_resources do |deployment|
  deployment.configured_resources.values.flatten.map do |resource|
    partial 'foreman_deployments/api/v2/resources/main', object: resource
  end
end
