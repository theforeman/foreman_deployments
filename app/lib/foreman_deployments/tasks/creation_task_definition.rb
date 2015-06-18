module ForemanDeployments
  module Tasks
    class CreationTaskDefinition < BaseDefinition
      class Action < BaseAction
        def run
          obj = CreationTaskDefinition.create_object(input)
          obj.save!
          CreationTaskDefinition.create_output(obj, output)
        end
      end

      def validate
        obj = CreationTaskDefinition.create_object(parameters)
        obj.valid?

        ValidationResult.new(obj.errors.messages)
      end

      def preliminary_output(parameters)
        CreationTaskDefinition.create_output(CreationTaskDefinition.create_object(parameters))
      end

      def dynflow_action
        ForemanDeployments::Tasks::CreationTaskDefinition::Action
      end

      def self.create_object(parameters)
        object_type = parameters['klass']
        object_params = parameters['params']

        object_type = object_type.constantize if object_type.is_a? String
        object_type.new(object_params)
      end

      def self.create_output(obj, output_hash = {})
        output_hash['object'] = obj
        output_hash
      end
    end
  end
end
