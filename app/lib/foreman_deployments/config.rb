module ForemanDeployments
  module Config
    class InvalidValueException < ::Foreman::Exception; end

    def self.cast_to_configuration(value)
      case value
      when ::Hash
        ForemanDeployments::Config::Hash[value.map { |key, obj| [key, cast_to_configuration(obj)] }]
      when ::Array
        ForemanDeployments::Config::Array[*value.map { |obj| cast_to_configuration(obj) }]
      else
        value
      end
    end
  end
end
