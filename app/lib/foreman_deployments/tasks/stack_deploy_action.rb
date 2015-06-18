module ForemanDeployments
  module Tasks
    class StackDeployAction < BaseAction
      def plan(stack_definition)
        stack_definition.accept(ForemanDeployments::PlannerVisitor.new(self))
        plan_self
      end
    end
  end
end
