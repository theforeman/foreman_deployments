module ForemanDeployments
  module ResourceModels
    #
    class CreateResource < ActiveModel::Model
      include ActiveModel::Dirty
      include ActiveModel::Conversion
      extend ActiveModel::Naming

      attr_accessor :resource_type, :definition_hash, :computed_hash

      def new_resource
        computed_hash ||= definition_hash

        resource_type.new computed_hash
      end
    end
  end
end
