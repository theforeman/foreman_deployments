module ForemanDeployments
  module DeploymentAssociations
    class Hostgroup < Abstract
      define_association ::Hostgroup, Resource::Hostgroup
    end
  end
end
