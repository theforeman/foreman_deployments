module ForemanDeployments
  class BaseDereferenceVisitor
    def initialize
      @task_cache = {}
    end

    def visit(subject)
      return unless subject.is_a? ForemanDeployments::Tasks::BaseDefinition
      visit_task_definition(subject)
    end

    protected

    def visit_task_definition(definition)
      definition.parameters = dereference(definition.parameters)
    end

    def dereference(value)
      case value
      when ForemanDeployments::TaskReference
        return get_dereference(value)
      when Config::Array
        return value.transform! { |obj| dereference(obj) }
      when Config::Hash
        return value.transform! { |key, obj| [key, dereference(obj)] }
      else
        return value
      end
    end

    def get_dereference(_ref)
      fail NotImplementedError, "Method 'get_dereference' needs to be implemented"
    end

    def cached(task)
      key = cache_key(task)
      if cached?(task)
        @task_cache[key]
      else
        @task_cache[key] = yield
      end
    end

    def cached?(task)
      @task_cache.key?(cache_key(task))
    end

    private

    def cache_key(task)
      task.task_id.to_s
    end
  end
end
