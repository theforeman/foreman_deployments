module ForemanDeployments
  module Validation
    class ValidationVisitor
      def visit(subject)
        validate_task_definition(subject) if subject.is_a? ForemanDeployments::Tasks::BaseDefinition
      end

      def result
        @result ||= ForemanDeployments::Validation::ValidationResult.new
      end

      private

      def validate_task_definition(subject)
        task_result = subject.validate
        result.messages[subject.task_id] = task_result.messages unless task_result.valid?
      end
    end
  end
end
