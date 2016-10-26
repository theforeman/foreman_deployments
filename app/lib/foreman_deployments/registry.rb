module ForemanDeployments
  class Registry
    class TypeException < ::Foreman::Exception; end

    ALLOWED_TYPES = {
      'task' => 'ForemanDeployments::Tasks::BaseDefinition',
      'input' => 'ForemanDeployments::Inputs::BaseInputDefinition'
    }.freeze

    def initialize
      clear!
    end

    def clear!
      @available = Hash[ALLOWED_TYPES.keys.map { |k| [k, {}] }]
    end

    def available(type)
      @available[type].clone
    end

    def register(type, registered_class)
      type = type.to_s
      unless type_valid?(type)
        fail(TypeException, "Type needs to be one of: #{ALLOWED_TYPES.keys.join(', ')}")
      end
      unless class_valid?(type, registered_class)
        fail(TypeException, "Registered class need to be descendant of #{ALLOWED_TYPES[type]}")
      end
      task_name = registered_class.tag_name.to_s
      unless name_valid?(task_name)
        fail(TypeException, "Invalid name #{task_name}")
      end
      @available[type][task_name.to_s] = registered_class.name
    end

    def available_tasks
      available('task')
    end

    def register_task(registered_class)
      register('task', registered_class)
    end

    def available_inputs
      available('input')
    end

    def register_input(registered_class)
      register('input', registered_class)
    end

    private

    def name_valid?(name)
      name =~ /[a-zA-Z0-9][a-zA-Z0-9_]*/
    end

    def class_valid?(type, registered_class)
      registered_class < ALLOWED_TYPES[type].constantize
    end

    def type_valid?(type)
      ALLOWED_TYPES.keys.include?(type)
    end
  end
end
