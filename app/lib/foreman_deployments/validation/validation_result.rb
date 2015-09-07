module ForemanDeployments
  module Validation
    class ValidationResult
      attr_accessor :messages

      def initialize(messages = {})
        fail('messages need to be either hash or array') if !messages.is_a?(Array) && !messages.is_a?(Hash)
        @messages = messages
      end

      def valid?
        @messages.empty?
      end

      def to_s
        if @messages.is_a?(Array)
          @messages.join("\n")
        else
          @messages.collect do |key, message|
            "#{key}: #{message}"
          end.join("\n")
        end
      end
    end
  end
end
