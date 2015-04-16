object @resource

extends 'foreman_deployments/api/v2/resources/main'

node do |resource|
  partial "foreman_deployments/api/v2/resources/types/#{resource.class.to_s.demodulize.underscore}.json",
          :object => resource
end

node nil, if: -> resource { resource.is_a?(ForemanDeployments::Resource::Ordered) } do |resource|
  partial 'foreman_deployments/api/v2/resources/types/ordered.json',
          :object => resource
end


