module ForemanDeployments
  class StackDefinition
    attr_accessor :tasks

    def initialize(tasks = {})
      @tasks = tasks
      initialize_tasks
    end

    def accept(visitor)
      tasks.each do |_task_id, task|
        task.accept(visitor)
      end
      visitor.visit(self)
    end

    private

    def initialize_tasks
      tasks.each do |task_id, task|
        task.task_id = task_id.to_s
      end
    end
  end
end
