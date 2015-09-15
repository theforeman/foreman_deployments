module ForemanDeployments
  module Inputs
    class Value < BaseInputDefinition
      attr_reader :description

      def initialize(params = {})
        @description = params.delete('description')
        @default = params.delete('default')
        super
      end

      def configured
        @configured || @default
      end

      def to_hash
        super.merge(
          'description' => @description,
          'default' => @default,
          'value' => @configured
        )
      end
    end
  end
end
