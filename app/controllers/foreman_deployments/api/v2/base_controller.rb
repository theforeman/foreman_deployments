require_dependency 'foreman_deployments/stack_parser'

module ForemanDeployments
  module Api
    module V2
      class BaseController < ::Api::V2::BaseController
        rescue_from StackParseException, :with => :unprocessable_entity_error

        resource_description do
          api_version 'v2'
        end

        def unprocessable_entity_error(exception)
          render_error 'standard_error', :locals => { :exception => exception }, :status => :unprocessable_entity
        end

        def resource_class_for(resource)
          return "ForemanDeployments::#{resource.classify}".constantize
        rescue NameError
          super
        end
      end
    end
  end
end
