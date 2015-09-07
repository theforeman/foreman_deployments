module ForemanDeployments
  module Validation
    class ValidationError < ::Foreman::Exception
      attr_accessor :validation_result

      def initialize(validation_result, message, *params)
        @validation_result = validation_result
        super(message, params)
      end
    end
  end
end
