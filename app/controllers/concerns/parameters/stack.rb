module Parameters
  module Stack
    extend ActiveSupport::Concern
    include Foreman::Controller::Parameters::Taxonomix

    class_methods do
      def stack_params_filter
        Foreman::ParameterFilter.new(::ForemanDeployments::Stack).tap do |filter|
          filter.permit :name, :definition

          add_taxonomix_params_filter(filter)
        end
      end
    end

    def stack_params
      self.class.stack_params_filter.filter_params(params, parameter_filter_context)
    end
  end
end
