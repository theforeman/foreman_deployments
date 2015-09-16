module ForemanDeployments
  module Tasks
    class BaseDefinition
      attr_accessor :task_id, :parameters
      attr_reader :planned

      def initialize(params = {})
        params ||= {}
        @task_id = task_id
        @parameters = HashWithIndifferentAccess[params]
      end

      def plan(parent_task)
        @planned ||= parent_task.send(:plan_action, dynflow_action, parameters)
      end

      def dynflow_action
        fail NotImplementedError, "Method 'dynflow_action' method needs to be implemented"
      end

      def validate
        fail NotImplementedError, "Method 'validate' needs to be implemented"
      end

      def preliminary_output(_parameters)
        fail NotImplementedError, "Method 'preliminary_output' needs to be implemented"
      end

      def configure(additional_parameters)
        @parameters = @parameters.deep_merge(additional_parameters)
      end

      def accept(visitor)
        visit_parameters(visitor, parameters)
        visitor.visit(self)
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
