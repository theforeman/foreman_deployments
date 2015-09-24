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
        obj = self.class.create_object(parameters.configured)
        obj.valid?
        ForemanDeployments::Validation::ValidationResult.new(obj.errors.full_messages)
      rescue ActiveRecord::ActiveRecordError => e
        ForemanDeployments::Validation::ValidationResult.new(e.message)
      end

      def preliminary_output
        self.class.create_output(self.class.create_object(parameters.configured))
      end

      def dynflow_action
        self.class::Action
      end

      def self.create_object(parameters)
        object_type = parameters['class']
        object_params = parameters['params'] || {}

        object_type = object_type.constantize if object_type.is_a? String
        object = object_type.new

        set_parameters(object, object_params)
      end

      def self.set_parameters(object, object_params)
        object_params.each do |key, value|
          if object.respond_to?("#{key}=")
            object.send("#{key}=", value)
            # TODO: else, add warning message
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

      def self.build(parameters)
        case parameters['class']
        when 'Host', 'Host::Managed'
          HostCreationTaskDefinition.new(parameters)
        else
          CreationTaskDefinition.new(parameters)
        end
      end
    end
  end
end
