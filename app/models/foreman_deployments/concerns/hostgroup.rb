module ForemanDeployments
  module Concerns
    module Hostgroup
      extend ActiveSupport::Concern

      included do
        has_many :deployments,
                 through:    :deployment_associations_hostgroups,
                 class_name: 'ForemanDeployments::Deployment'

        has_many :resources,
                 through:    :deployment_associations_hostgroups,
                 class_name: 'ForemanDeployments::Resource::Abstract'

        has_many :deployment_associations_hostgroups,
                 foreign_key: :hostgroup_id,
                 class_name:  'ForemanDeployments::DeploymentAssociations::Hostgroup' # private

        # TODO scoped_search
      end
    end
  end
end
