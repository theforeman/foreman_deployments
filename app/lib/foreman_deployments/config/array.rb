module ForemanDeployments
  module Config
    class Array < ::Array
      def configure(values)
        values = ensure_hash(values)
        values.map do |index, value|
          configure_index(index, value)
        end
      end

      def configured
        map.with_index do |item, index|
          if item.respond_to?(:configured)
            item.configured
          elsif item.nil?
            configuration_storage[index]
          else
            item
          end
        end
      end

      def configuration
        result = configuration_storage.deep_clone
        each_with_index do |item, index|
          if item.respond_to?(:configuration)
            result[index] = item.configuration unless item.configuration.nil?
          end
        end
        result.empty? ? nil : result
      end

      def transform!(&block)
        self.map! do |item|
          block.call(item)
        end
        self
      end

      protected

      def configuration_storage
        @configuration_storage ||= {}
      end

      def ensure_hash(values)
        if values.is_a? ::Hash
          ::Hash[values.map { |index, value| sanitize_pair(index, value) }]
        elsif values.is_a? ::Array
          ::Hash[values.map.with_index { |value, index| sanitize_pair(index, value) }]
        else
          fail("Unexpected type #{values.class}")
        end
      end

      def sanitize_pair(index, value)
        index = Integer(index)
        if (index >= size) || (index < 0)
          fail(InvalidValueException, _('Can\'t configure items outside the range'))
        end
        [index, value]
      rescue ArgumentError
        raise(InvalidValueException, _("Keys '%s' isn't numeric value") % index)
      end

      def configure_index(index, value)
        preconfigured = self[index]

        if preconfigured.nil?
          if value.nil?
            configuration_storage.delete(index)
          else
            configuration_storage[index] = value
          end
        elsif preconfigured.respond_to?(:configure)
          preconfigured.configure(value)
        else
          fail(InvalidValueException, _("You can't override values hardcoded in the stack definition"))
        end
      end
    end
  end
end
