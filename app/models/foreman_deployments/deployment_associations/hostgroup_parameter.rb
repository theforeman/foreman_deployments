module ForemanDeployments
  module DeploymentAssociations
    class HostgroupParameter < Abstract
      define_association ::GroupParameter, Resource::HostgroupParameter
    end
  end
end
