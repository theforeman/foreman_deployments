module ForemanDeployments
  module Inputs
    class BaseInputDefinition
      attr_reader :configured

      def initialize(params = {})
        @parameters = params
      end

      def validate(_value)
        ValidationResult.new
      end

      def configure(value)
        validate(value)
        @configured = value
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
    end
  end
end
