#
module ForemanDeployments
  #
  class TaskDefinition
    attr_accessor :task_class, :params
    attr_accessor :parent_task, :definitions
    attr_accessor :dependent_on

    def initialize(parent_task, definitions, task_class, params)
      @parent_task, @definitions = parent_task, definitions
      @task_class, @params = task_class, params
      @dependent_on = []

      # check dependencies
      dereference(@params) do |task_ref|
        @dependent_on << task_ref.task_id
      end
    end

    def validate
      return @validated if @validated

      params = remove_ids(@params)

      params = dereference(params) do |task_ref|
        task_ref.dereference(@definitions[task_ref.task_id].validate.output)
      end

      @validated = @task_class.get_validation_object(params)
      throw 'validation object should inherit from ValidationResult' unless @validated.is_a? ValidationResult
      @validated.validate!
    end

    def plan
      return @task if @task

      params = dereference(@params) do |task_ref|
        task_ref.dereference(@definitions[task_ref.task_id].plan.output)
      end

      @task = @parent_task.send(:plan_action, @task_class, params)
    end

    def dereference(value, &func)
      return func.call(value) if value.is_a? TaskReference
      return value.map { |obj| dereference(obj, &func) } if value.is_a? Array
      return Hash[value.map { |key, obj| [key, dereference(obj, &func)] }] if value.is_a? Hash
      value
    end

    def remove_ids(hash)
      pairs = hash.map do |key, value|
        if key.to_s.end_with?('_id') && value.is_a?(TaskReference)
          [key.to_s.sub('_id', ''), value]
        elsif key.to_s.end_with?('_ids') && value.select { |i| i.is_a?(TaskReference) }.any?
          [key.to_s.sub('_id', ''), value]
        elsif value.is_a? Hash
          [key, remove_ids(value)]
        else
          [key, value]
        end
      end
      Hash[pairs]
    end
  end
end
