module ForemanDeployments
  class InvalidTaskException < ::Foreman::Exception; end

  class TaskRegistry
    def initialize
      clear!
    end

    def clear!
      @available_tasks = {}
    end

    def available_tasks
      @available_tasks.clone
    end

    def register_task(task_name, task_class)
      task_name = task_name.to_s
      unless task_name_valid?(task_name)
        fail(InvalidTaskException, "Invalid task name #{task_name}")
      end
      unless task_class_valid?(task_class)
        fail(InvalidTaskException, 'Task class need to be descendant of ForemanDeployments::Tasks::Base')
      end
      @available_tasks[task_name.to_s] = task_class
    end

    private

    def task_name_valid?(name)
      name =~ /[a-zA-Z0-9][a-zA-Z0-9_]*/
    end

    def task_class_valid?(task_class)
      task_class < ForemanDeployments::Tasks::BaseDefinition
    end
  end
end
