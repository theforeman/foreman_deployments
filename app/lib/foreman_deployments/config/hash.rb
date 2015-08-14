module ForemanDeployments
  module Config
    class Hash < ActiveSupport::HashWithIndifferentAccess
      def configure(values)
        values.each do |key, value|
          configure_key(key, value)
        end
      end

      def configured
        result = configuration_storage.deep_clone
        each do |key, item|
          if item.respond_to?(:configured)
            result[key.to_s] = item.configured
          else
            result[key.to_s] = item
          end
        end
        result
      end

      def configuration
        result = configuration_storage.deep_clone
        each do |key, value|
          if value.respond_to?(:configuration)
            result[key.to_s] = value.configuration unless value.configuration.nil?
          end
        end
        result.empty? ? nil : result
      end

      def transform!(&block)
        keys.each do |key|
          new_key, new_value = block.call(key, self[key])
          self[key] = new_value
          self[new_key] = delete(key) if new_key != key
        end
        self
      end

      protected

      def configuration_storage
        @configuration_storage ||= {}
      end

      def configure_key(key, value)
        preconfigured = self[key]

        if preconfigured.nil?
          update_configuration_storage(key, value)
        elsif preconfigured.respond_to?(:configure)
          preconfigured.configure(value)
        else
          fail(InvalidValueException, _("You can't override values hardcoded in the stack definition"))
        end
      end

      def update_configuration_storage(key, value)
        if value.is_a? ::Hash
          self[key] = Config::Hash.new
          self[key].configure(value)
        elsif value.is_a? ::Array
          self[key] = Config::Array.new(value.size)
          self[key].configure(value)
        elsif value.nil?
          configuration_storage.delete(key.to_s)
        else
          configuration_storage[key.to_s] = value
        end
      end
    end
  end
end
