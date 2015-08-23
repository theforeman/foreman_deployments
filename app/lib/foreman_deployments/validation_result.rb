module ForemanDeployments
  class ValidationResult
    attr_accessor :messages

    def initialize(messages = {})
      @messages = messages
    end

    def valid?
      @messages.empty?
    end
  end
end
