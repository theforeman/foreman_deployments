module ForemanDeployments
  module Config
    class MergeVisitor
      def initialize(config_storage)
        @config_storage = config_storage
      end

      def visit(subject)
        configure_task_definition(subject) if subject.is_a? ForemanDeployments::Tasks::BaseDefinition
      end

      def self.merge(stack_definition, config_storage)
        stack_definition.accept(MergeVisitor.new(config_storage))
      end

      private

      def configure_task_definition(task)
        task.merge_configuration(@config_storage.get_config_for(task))
      end
    end
  end
end
