module ForemanDeployments
  module Validation
    class DereferenceVisitor < ForemanDeployments::BaseDereferenceVisitor
      protected

      def get_dereference(ref)
        ref.dereference(get_preliminary_output(ref.task))
      end

      def get_preliminary_output(task)
        cached(task) do
          task.preliminary_output(dereference(task.parameters))
        end
      end
    end
  end
end
