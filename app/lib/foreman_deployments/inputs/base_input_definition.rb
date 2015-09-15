module ForemanDeployments
  module Inputs
    class BaseInputDefinition
      attr_reader :configured

      def initialize(params = {})
        @parameters = params
      end

      def validate(_value)
        ForemanDeployments::Validation::ValidationResult.new
      end

      def configure(value)
        validate(value)
        @configured = value
      end

      def configuration
        @configured
      end

      def to_hash
        {
          '_type' => 'input',
          '_name' => self.class.tag_name
        }
      end

      def self.tag_name
        name.split('::').last
      end

      def self.build(*params)
        new(params)
      end
    end
  end
end
