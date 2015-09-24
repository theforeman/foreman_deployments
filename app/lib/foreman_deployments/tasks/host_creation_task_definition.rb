module ForemanDeployments
  module Tasks
    class HostCreationTaskDefinition < ForemanDeployments::Tasks::CreationTaskDefinition
      class Action < BaseAction
        def run
          obj = HostCreationTaskDefinition.create_object(input)
          obj.save!
          HostCreationTaskDefinition.create_output(obj, output)
        end
      end

      def self.create_object(parameters)
        object_type = parameters['class']
        object_params = parameters['params']
        object_params['managed'] ||= true

        object_type = object_type.constantize if object_type.is_a? String

        initial_params = {
          :interfaces_attributes => object_params.delete('interfaces_attributes') || {}
        }

        object = object_type.new(initial_params)
        object = set_parameters(object, object_params)

        if object.is_a? Host::Managed
          object_params['build'] ||= true
          # Set compute attributes from a compute profile
          if object.compute_resource_id && object.compute_profile_id
            profile_attributes = object.compute_resource.compute_profile_attributes_for(object.compute_profile_id)
            object.compute_attributes = profile_attributes.merge(object.compute_attributes || {})
          end
          # Merge interfaces from a compute profile
          merge = InterfaceMerge.new
          merge.run(object.interfaces, object.compute_resource.try(:compute_profile_for, object.compute_profile_id))
        end

        object
      end
    end
  end
end
