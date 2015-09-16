module ForemanDeployments
  module Validation
    class DereferenceVisitor < ForemanDeployments::BaseDereferenceVisitor
      protected

      def get_dereference(ref)
        ref.dereference(get_preliminary_output(ref.task))
      end

      def get_preliminary_output(task)
        cached(task) do
          task.parameters = dereference(task.parameters)
          task.preliminary_output
        end
      end
    end
  end
end
