module ForemanDeployments
  module Validation
    class Validator
      def validate(stack_definition)
        cloned = stack_definition.deep_clone

        cloned.accept(ForemanDeployments::Validation::RemoveIdsVisitor.new)
        cloned.accept(ForemanDeployments::Validation::DereferenceVisitor.new)
        validation_visitor = ForemanDeployments::Validation::ValidationVisitor.new
        cloned.accept(validation_visitor)

        validation_visitor.result
      end

      def self.validate(stack_definition)
        Validator.new.validate(stack_definition)
      end
    end
  end
end
