module ForemanDeployments
  module Resource

    class HostgroupParameter < Resource::Parameter
      belongs_to :hostgroup, class_name: 'ForemanDeployments::Resource::Hostgroup'
      ensure_association_present :hostgroup

      has_many :associated_hostgroups_parameters,
               foreign_key: :resource_id,
               class_name:  'ForemanDeployments::DeploymentAssociations::HostgroupParameter'


      def self.configurable?
        true
      end

      def self.out_of_phase?
        true
      end

      def self.configurable(stack)
        in_stack(stack)
      end

      # @override
      def self.configured_in(deployment)
        configurable(deployment.stack).
            includes(:associated_hostgroups_parameters => :group_parameter).
            where(DeploymentAssociations::HostgroupParameter.table_name => { deployment_id: deployment }).
            where("#{::GroupParameter.table_name}.value IS NOT NULL")
      end

      def self.configure_after
        %w[ForemanDeployments::Resource::Hostgroup]
      end

      def configure(deployment, value)
        group_parameter(deployment).update_attributes!(value: value)
      end

      def configuration(deployment)
        [group_parameter(deployment).value]
      end

      def group_parameter(deployment)
        dahp = DeploymentAssociations::HostgroupParameter.
            where(resource_id: self, deployment_id: deployment).
            first
        dahp && dahp.group_parameter
      end

      # TODO omit parameters already provided, or allow to define inherit instead a value
      def before_configure(deployment)
        foreman_hostgroup = ::Hostgroup.includes(:resources).where(Resource::Hostgroup.table_name => { id: hostgroup }).first

        DeploymentAssociations::HostgroupParameter.create!(
            deployment:      deployment,
            resource:        self,
            group_parameter: ::GroupParameter.new(
                name:      name,
                value:     value,
                hostgroup: foreman_hostgroup))
      end
    end
  end
end
