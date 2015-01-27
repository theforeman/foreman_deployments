module ForemanDeployments
  class Deployment < ActiveRecord::Base
    include Authorizable
    include Taxonomix

    self.table_name = ForemanDeployments::TABLE_PREFIX + 'deployments'
    scoped_search :on => :name, :complete_value => :true

    has_one :stack, :through => :stack_deployment
    has_many :resources, :through => :stacks

    # TODO consider more stacks per deployment
    has_one :stack_deployment # private

    after_save { run_before_configure configuration_phases.first }

    # TODO query-able by type
    # @return [Hash{Class => Array<Resource::Abstract>}]
    def configurable_resources
      reduce_configuration_phases { |resource_class| resource_class.configurable(stack) }
    end

    # TODO query-able by type
    # @return [Hash{Class => Array<Resource::Abstract>}]
    def configured_resources
      reduce_configuration_phases { |resource_class| resource_class.configured_in(self) }
    end

    # TODO query-able by type
    # @return [Hash{Class => Array<Resource::Abstract>}]
    def not_configured_resources
      reduce_configuration_phases { |resource_class| resource_class.not_configured_in(self) }
    end

    # @param [Resource::Abstract] resource
    # @param *args matching `resource.configure` method header
    def configure_resource(resource, *args)
      Resource::Abstract.ensure_configurable resource
      starting_configuration_phase = configuration_phase
      unless can_be_configured? resource.class
        raise ArgumentError,
              "A resource of type #{resource.class} cannot be configured right now, #{starting_configuration_phase} is now being configured"
      end
      resource.configure self, *args

      # prepare for next phase if applicable
      next_configuration_phase = configuration_phase
      if next_configuration_phase != starting_configuration_phase && next_configuration_phase
        run_before_configure next_configuration_phase
      end
    end

    def resource_configuration(resource)
      Resource::Abstract.ensure_configurable resource
      resource.configuration resource
    end

    # @return [Class] type of the Resource::Abstract being configured, first not fully configured type of resources
    def configuration_phase
      phase = not_configured_resources.find { |_, resources| not resources.empty? }
      phase ? phase.first : nil
    end

    # @return [Class] all resource types needed to be configured in order in which they need to be configured
    def configuration_phases
      ForemanDeployments::Resource::Abstract.configuration_order
    end

    private

    def can_be_configured?(resource_class, current_phase = configuration_phase)
      current_index        = current_phase.nil? ? Float::INFINITY : configuration_phases.index(current_phase)
      resource_class_index = configuration_phases.index(resource_class)

      if resource_class.out_of_phase?
        current_index >= resource_class_index
      else
        current_index == resource_class_index
      end
    end

    def reduce_configuration_phases(&block)
      configuration_phases.reduce({}) do |hash, resource_class|
        hash.update resource_class => block.call(resource_class)
      end
    end

    def run_before_configure(phase)
      not_configured_resources[phase].each { |resource| resource.before_configure self }
    end

  end
end
