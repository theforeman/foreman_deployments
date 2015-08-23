module ForemanDeployments
  class PlannerVisitor < BaseDereferenceVisitor
    def initialize(parent_action)
      super()
      @parent_action = parent_action
    end

    protected

    def visit_task_definition(task)
      super
      task.plan(@parent_action) unless cached?(task)
    end

    def get_dereference(ref)
      ref.dereference(get_planned_output(ref.task))
    end

    def get_planned_output(task)
      cached(task) do
        task.parameters = dereference(task.parameters)
        task.plan(@parent_action).output
      end
    end
  end
end
