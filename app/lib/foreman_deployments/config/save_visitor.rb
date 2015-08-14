module ForemanDeployments
  module Config
    class SaveVisitor
      def initialize(config_storage)
        @config_storage = config_storage
      end

      def visit(subject)
        configure_task_definition(subject) if subject.is_a? ForemanDeployments::Tasks::BaseDefinition
      end

      def self.save(stack_definition, config_storage)
        stack_definition.accept(SaveVisitor.new(config_storage))
      end

      private

      def configure_task_definition(task)
        @config_storage.set_config_for(task, task.configuration)
      end
    end
  end
end
