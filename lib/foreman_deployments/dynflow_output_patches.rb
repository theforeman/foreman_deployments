module Dynflow
  module ForemanDeploymentsExtensions
    module OutputReferenceExtensions
      def dereference(persistence)
        action_data = persistence.adapter.load_action(execution_plan_id, action_id)
        action = action_data[:class].constantize
        if action.respond_to? :dereference_output
          action.dereference_output(action_data, @subkeys)
        else
          super
        end
      end
    end
  end

  class ExecutionPlan::OutputReference
    prepend Dynflow::ForemanDeploymentsExtensions::OutputReferenceExtensions
  end
end
