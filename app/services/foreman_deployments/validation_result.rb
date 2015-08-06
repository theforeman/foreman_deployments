module ForemanDeployments
  #
  class ValidationResult
    attr_accessor :output, :validate_proc
    def initialize(output, &validate)
      @output = output
      @validate_proc = validate
    end

    def validate!
      @validate_proc.call(output)
    end
  end
end
