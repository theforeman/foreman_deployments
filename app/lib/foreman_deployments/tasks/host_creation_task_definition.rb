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

        object = set_parameters(object_type.new, object_params)

        if object.is_a? Host::Managed
          object_params['build'] ||= true
          # Set attributes from a hostgroup
          object.attributes = object.apply_inherited_attributes(object_params)
          # Set compute attributes from a compute profile
          if object.compute_resource_id && object.compute_profile_id
            profile_attributes = object.compute_resource.compute_profile_attributes_for(object.compute_profile_id)
            object.compute_attributes = profile_attributes.merge(object.compute_attributes)
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
