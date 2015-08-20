require 'foreman_deployments/stack_parser'

module ForemanDeployments
  module Api
    module V2
      class BaseController < ::Api::V2::BaseController
        rescue_from StackParseException, :with => :stack_parse_error

        resource_description do
          api_version 'v2'
        end

        def stack_parse_error(exception)
          render_error 'standard_error', :locals => { :exception => exception }, :status => :unprocessable_entity
        end
      end
    end
  end
end
