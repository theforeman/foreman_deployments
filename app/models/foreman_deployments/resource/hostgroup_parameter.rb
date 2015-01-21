module ForemanDeployments
  module Resource

    # TODO abstract creation: before, configure
    class HostgroupParameter < Resource::Parameter
      belongs_to :hostgroup, class_name: 'ForemanDeployments::Resource::Hostgroup'
      ensure_association_present :hostgroup

      def self.configurable?
        true
      end

      def self.configurable(stack)
        in_stack(stack)
      end

      # @override
      def self.configured_in(deployment)
        where(id: 0) # TODO implement configured parameter detection
      end

      def self.configure_after
        %w[ForemanDeployments::Resource::Hostgroup]
      end

      def configure(deployment)
        super # TODO implement
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
