#
module ForemanDeployments
  class InvalidValidationOutputException < ::Foreman::Exception; end

  #
  class TaskDefinition
    attr_accessor :task_class, :params
    attr_accessor :definitions

    def initialize(definitions, task_class, params)
      @definitions = definitions
      @task_class, @params = task_class, params
    end

    def validate
      return @validated if @validated

      params = prepare_params

      @validated = @task_class.get_validation_object(params)
      unless @validated.is_a? ValidationResult
        throw InvalidValidationOutputException
      end
      @validated.validate!
      @validated
    end

    def plan(parent_task)
      return @task if @task

      params = dereference(@params) do |task_ref|
        task_output = @definitions[task_ref.task_id].plan(parent_task).output
        task_ref.dereference(task_output)
      end

      @task = parent_task.send(:plan_action, @task_class, params)
    end

    private

    def dereference(value, &func)
      case value
      when TaskReference
        return func.call(value)
      when Array
        return value.map { |obj| dereference(obj, &func) }
      when Hash
        return Hash[value.map { |key, obj| [key, dereference(obj, &func)] }]
      else
        return value
      end
    end

    def remove_ids(hash)
      pairs = hash.map do |key, value|
        transform_pair(key, value)
      end
      Hash[pairs]
    end

    def transform_pair(key, value)
      if singular_reference?(key, value)
        [key.to_s.sub('_id', ''), value]
      elsif multiple_references?(key, value)
        [key.to_s.sub('_id', ''), value]
      elsif value.is_a? Hash
        [key, remove_ids(value)]
      else
        [key, value]
      end
    end

    def singular_reference?(key, value)
      key.to_s.end_with?('_id') && value.is_a?(TaskReference)
    end

    def multiple_references?(key, value)
      key.to_s.end_with?('_ids') && value.any? { |i| i.is_a?(TaskReference) }
    end

    def prepare_params
      params = remove_ids(@params)

      params = dereference(params) do |task_ref|
        task_ref.dereference(@definitions[task_ref.task_id].validate.output)
      end

      params
    end
  end
end
