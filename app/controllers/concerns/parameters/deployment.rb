module Parameters
  module Deployment
    extend ActiveSupport::Concern

    class_methods do
      def deployment_params_filter
        Foreman::ParameterFilter.new(::ForemanDeployments::Deployment).tap do |filter|
          filter.permit(
            :name,
            :stack_id,
            :location, :location_id, :location_name,
            :organization, :organization_id, :organization_name
          )
        end
      end
    end

    def deployment_params
      self.class.deployment_params_filter.filter_params(params, parameter_filter_context)
    end
  end
end
