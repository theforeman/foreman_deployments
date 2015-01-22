module ForemanDeployments
  module Resource
    class Hostgroup < Abstract
      # parent
      belongs_to :hostgroup, class_name: 'ForemanDeployments::Resource::Hostgroup'

      has_many :parameters, class_name: 'ForemanDeployments::Resource::HostgroupParameter'
      has_many :hosts, class_name: 'ForemanDeployments::Resource::Host'
      has_many :puppetclasses, class_name: 'ForemanDeployments::Resource::PuppetClass'

      has_many :associated_hostgroups,
               foreign_key: :resource_id,
               class_name:  'ForemanDeployments::DeploymentAssociations::Hostgroup'

      validates :name, presence: true

      # TODO show deployment relation in the hostgroup table

      def self.configurable?
        true
      end

      def self.out_of_phase?
        true
      end

      def self.configurable(stack)
        in_stack(stack).where(hostgroup_id: nil)
      end

      def self.configured_in(deployment)
        in_stack(deployment.stack).
            includes(:associated_hostgroups).
            where(DeploymentAssociations::Hostgroup.table_name => { deployment_id: deployment })
      end

      def before_configure(deployment)
        # do nothing
      end

      # TODO dry
      def hostgroup(deployment)
        dahg = DeploymentAssociations::Hostgroup.
            where(resource_id: self, deployment_id: deployment).
            first
        dahg && dahg.hostgroup
      end

      def configure(deployment, parent)
        hostgroup = hostgroup(deployment)

        if hostgroup
          hostgroup.update_attributes! parent_id: parent
        else
          hostgroup = ::Hostgroup.new name:      format('%s (%s)', name, deployment.name),
                                      parent_id: parent
          hostgroup.save! # TODO in transaction
          DeploymentAssociations::Hostgroup.create! resource: self, deployment: deployment, hostgroup: hostgroup

          # TODO create all child hostgroups, missing association definition, after child stacks are added
        end
      end

    end
  end
end
