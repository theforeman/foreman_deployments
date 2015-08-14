module ForemanDeployments
  module Tasks
    class CreationTaskDefinition < ForemanDeployments::Tasks::BaseDefinition
      class Action < BaseAction
        def run
          obj = CreationTaskDefinition.create_object(input)
          obj.save!
          CreationTaskDefinition.create_output(obj, output)
        end
      end

      def validate
        obj = CreationTaskDefinition.create_object(parameters.configured)
        obj.valid?
        ValidationResult.new(obj.errors.full_messages)
      rescue ActiveRecord::ActiveRecordError => e
        ValidationResult.new(e.message)
      end

      def preliminary_output(parameters)
        CreationTaskDefinition.create_output(CreationTaskDefinition.create_object(parameters.configured))
      end

      def dynflow_action
        ForemanDeployments::Tasks::CreationTaskDefinition::Action
      end

      def self.create_object(parameters)
        object_type = parameters['klass']
        object_params = parameters['params']

        object_type = object_type.constantize if object_type.is_a? String
        object = object_type.new
        object_params.each do |key, value|
          begin
            object.attributes = { key => value }
          rescue ActiveRecord::UnknownAttributeError => e
            # TODO: add this to warnings
            e.message
          end
        end
        object
      end

      def self.create_output(obj, output_hash = {})
        output_hash['object'] = obj
        output_hash
      end

      def self.tag_name
        'CreateResource'
      end
    end
  end
end
