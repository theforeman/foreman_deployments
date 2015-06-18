#
module ForemanDeployments
  #
  class TaskReference
    attr_accessor :task_id, :output_key

    def initialize(task_id, output_key)
      @task_id = task_id
      @output_key = output_key
    end

    def dereference(output)
      output[@output_key]
    end
  end
end
