module ForemanDeployments
  module Concerns
    module GroupParameter
      extend ActiveSupport::Concern

      included do
        has_many :deployments,
                 through:    :deployment_associations_hostgroup_parameters,
                 class_name: 'ForemanDeployments::Deployment'

        has_many :resources,
                 through:    :deployment_associations_hostgroup_parameters,
                 class_name: 'ForemanDeployments::Resource::Abstract'

        has_many :deployment_associations_hostgroup_parameters,
                 foreign_key: :hostgroup_id,
                 class_name:  'ForemanDeployments::DeploymentAssociations::HostgroupParameter' # private

        # TODO scoped_search
      end
    end
  end
end
