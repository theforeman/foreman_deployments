module ForemanDeployments
  module Resource
    class Host < Abstract
      belongs_to :hostgroup, class_name: 'ForemanDeployments::Resource::Hostgroup'
      ensure_association_present :hostgroup

      has_many :puppet_runs, class_name: 'ForemanDeployments::Resource::PuppetRun'

      # name (e.g. 'db-%02d}' to generate the names, possibly %g for group etc)
      validates :name, :min, :max, presence: true

      validates_each :max do |r, a, v|
        r.errors.add a, 'min has to be smaller or equal than max' if r.min > v
      end

      def self.configurable?
        true
      end

      def self.out_of_phase?
        false
      end

      def self.configure_after
        %w[ForemanDeployments::Resource::HostgroupParameter]
      end

      def self.configure_before
        []
      end

      def self.configurable(stack)
        in_stack(stack)
      end

      def self.configured_in(deployment)
        # FIXME more robust and fast
        in_stack(deployment.stack).select { |host| !host.configuration(deployment).empty? }
      end

      def before_configure(deployment)
        # do nothing
      end

      # TODO provision: true/false
      # TODO it supports only existing hosts now
      # FIXME do not allow reconfiguration! or remove already assigned hosts
      def configure(deployment, *args)
        case
        when args.all? { |h| h.is_a? ::Host::Base }
          configure_existing_hosts deployment, args
        when (count, compute_resource = args; count.is_a?(Integer) && compute_resource.is_a?(::ComputeResource))
          configure_compute_resource_hosts deployment, count, compute_resource
        else
          raise ArgumentError
        end
      end

      def configure_existing_hosts(deployment, hosts)
        hosts.each do |host|
          host.hostgroup = hostgroup.hostgroup(deployment)
          host.save!
        end
      end

      def configure_compute_resource_hosts(deployment, count, compute_resource)
        raise NotImplementedError
      end

      def ensure_count(count)
        if (min && count <= min) || (max && count >= max)
          raise ArgumentError
        end
      end

      def configuration(deployment)
        hostgroup = self.hostgroup.hostgroup(deployment)
        hostgroup && hostgroup.hosts
      end


    end
  end
end
