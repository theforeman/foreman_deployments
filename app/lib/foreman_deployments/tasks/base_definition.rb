module ForemanDeployments
  module Tasks
    class BaseDefinition
      attr_accessor :task_id, :parameters
      attr_reader :planned

      def initialize(params = nil)
        @parameters = ForemanDeployments::Config.cast_to_configuration(params || {})
      end

      def plan(parent_task)
        @planned ||= parent_task.send(:plan_action, dynflow_action, parameters.configured)
      end

      def dynflow_action
        fail NotImplementedError, "Method 'dynflow_action' method needs to be implemented"
      end

      def validate
        fail NotImplementedError, "Method 'validate' needs to be implemented"
      end

      def preliminary_output
        fail NotImplementedError, "Method 'preliminary_output' needs to be implemented"
      end

      def configure(parameters)
        @parameters.configure(parameters)
      end

      def merge_configuration(additional_parameters)
        @parameters.merge_configuration(additional_parameters)
      end

      def configuration
        @parameters.configuration
      end

      def accept(visitor)
        visit_parameters(visitor, parameters)
        visitor.visit(self)
      end

      def to_hash
        @parameters.configured.merge(
          '_type' => 'task',
          '_name' => self.class.tag_name
        )
      end

      def self.tag_name
        name.split('::').last
      end

      def self.build(params)
        new(params)
      end

      private

      def visit_parameters(visitor, value)
        if value.respond_to?(:accept)
          value.accept(visitor)
        elsif value.is_a? Array
          value.each { |item| visit_parameters(visitor, item) }
        elsif value.is_a? Hash
          value.each { |_key, item| visit_parameters(visitor, item) }
        end
      end
    end
  end
end
