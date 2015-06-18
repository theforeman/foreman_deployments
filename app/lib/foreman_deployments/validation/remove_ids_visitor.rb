module ForemanDeployments
  module Validation
    class RemoveIdsVisitor
      def visit(subject)
        if subject.is_a? ForemanDeployments::Tasks::BaseDefinition
          subject.parameters = remove_ids(subject.parameters)
        end
      end

      private

      def remove_ids(hash)
        pairs = hash.map do |key, value|
          transform_pair(key, value)
        end
        Hash[pairs]
      end

      def transform_pair(key, value)
        if singular_reference?(key, value)
          [key.to_s.sub('_id', ''), remove_id_from_reference(value)]
        elsif multiple_references?(key, value)
          [key.to_s.sub('_id', ''),  value.map { |item| remove_id_from_reference(item) }]
        elsif value.is_a? Hash
          [key, remove_ids(value)]
        else
          return [key, value]
        end
      end

      def singular_reference?(key, value)
        key.to_s.end_with?('_id') && value.is_a?(TaskReference)
      end

      def multiple_references?(key, value)
        key.to_s.end_with?('_ids') && value.any? { |i| i.is_a?(TaskReference) }
      end

      def remove_id_from_reference(ref)
        if ref.output_key.end_with?('.ids')
          ref.output_key.gsub!(/[.]ids$/, 's')
        elsif ref.output_key.end_with?('.id')
          ref.output_key.gsub!(/[.]id$/, '')
        end
        ref
      end
    end
  end
end
