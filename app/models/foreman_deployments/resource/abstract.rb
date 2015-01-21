module ForemanDeployments
  module Resource
    class Abstract < ActiveRecord::Base

      # does not do any validation, but it allows to write `validates :value, optional: true` documenting
      # what attributes resource has in the model
      class OptionalValidator < ActiveModel::EachValidator
        def validate(record)
        end
      end

      # allows to compute topological sort on Hash containing graph description
      class TSortHash < Hash
        include TSort
        alias_method :tsort_each_node, :each_key

        def tsort_each_child(node, &block)
          fetch(node).each(&block)
        end
      end

      extend EnsureAssociationPresent

      self.table_name = ForemanDeployments::TABLE_PREFIX + 'resources'

      belongs_to :stack, :class_name => 'ForemanDeployments::Stack'
      ensure_association_present :stack

      scoped_search :on => :name, :complete_value => :true

      def self.of_type(type)
        raise ArgumentError unless type <= self
        where type: type
      end

      # @returns [Array<Class>] order of configurable resources
      def self.configuration_order
        # TODO maybe cache
        Abstract.descendants.each_with_object(TSortHash.new) do |descendant, graph|
          graph.update descendant => descendant.configure_after.map(&:constantize) if descendant.configurable?
        end.tsort
      end

      def self.in_stack(stack)
        where stack_id: stack
      end

      # @override return true if the resource type needs configuration
      def self.configurable?
        false
      end

      # @override override and return on which types does this type depends, used in {.configuration_order}
      def self.configure_after
        []
      end

      # @override scope
      # @return all configurable instances of a given type (method receiver) within stack
      def self.configurable(stack)
        if configurable?
          raise NotImplementedError
        else
          where(id: 0)
        end
      end

      # @override scope
      # @return all already configured instances of a given type (method receiver) within deployment
      def self.configured_in(deployment)
        if configurable?
          raise NotImplementedError
        else
          where(id: 0)
        end
      end

      # @override scope
      # @return all not configured instances of a given type (method receiver) within deployment
      def self.not_configured_in(deployment)
        configurable(deployment.stack) - configured_in(deployment) # TODO optimize
      end

      # @override define steps to be made before configuration
      # @note triggers after moving to this type's configuration phase
      def before_configure(deployment, *args)
        if self.class.configurable?
          raise NotImplementedError
        else
          true
        end
      end

      # @override steps to be made on resource configuration
      def configure(deployment, *args)
        if self.class.configurable?
          raise NotImplementedError
        else
          true
        end
      end

      # @return [true, false] if configured in given deployment
      def configured_in?(deployment)
        self.class.configured_in(deployment).include? self
      end
    end

    # TODO document/ensure all plugins adding resource do eager load too
    Dir["#{ForemanDeployments::Engine.root}/app/models/foreman_deployments/resource/*"].each do |f|
      require_dependency f
    end
  end
end
