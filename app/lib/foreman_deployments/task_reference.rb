module ForemanDeployments
  class TaskReference
    attr_accessor :task, :task_id, :output_key

    def initialize(task_id, output_key, task = nil)
      @task_id = task_id
      @output_key = output_key
      @task = task
    end

    def dereference(output)
      output_keys.each do |key|
        return nil if output.nil?
        if output.is_a?(Hash) || output.is_a?(Dynflow::ExecutionPlan::OutputReference)
          output = output[key]
        else
          output = output.send(key)
        end
      end
      return output
    rescue NoMethodError
      return nil
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def to_hash
      {
        '_type' => 'reference',
        '_name' => self.class.tag_name,
        'object' => task_id,
        'field' => output_key
      }
    end

    def self.tag_name
      'reference'
    end

    private

    def output_keys
      @output_key.to_s.split('.')
    end
  end
end
