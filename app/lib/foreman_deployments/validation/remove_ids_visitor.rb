module ForemanDeployments
  module Validation
    class RemoveIdsVisitor
      def visit(subject)
        if subject.is_a? ForemanDeployments::Tasks::BaseDefinition
          remove_ids(subject.parameters)
        end
      end

      private

      def remove_ids(value)
        case value
        when Config::Hash
          remove_ids_from_hash(value)
        when Config::Array
          remove_ids_from_array(value)
        when TaskReference
          remove_id_from_reference(value)
        else
          value
        end
      end

      def remove_ids_from_hash(hash)
        hash.transform! do |key, item|
          if singular_reference?(key) || multiple_references?(key)
            [key.to_s.sub('_id', ''), remove_ids(item)]
          else
            [key, remove_ids(item)]
          end
        end
      end

      def remove_ids_from_array(array)
        array.transform! do |item|
          remove_ids(item)
        end
      end

      def remove_id_from_reference(ref)
        if ref.output_key.end_with?('.ids')
          ref.output_key.gsub!(/[.]ids$/, 's')
        elsif ref.output_key.end_with?('.id')
          ref.output_key.gsub!(/[.]id$/, '')
        end
        ref
      end

      def singular_reference?(key)
        key.to_s.end_with?('_id')
      end

      def multiple_references?(key)
        key.to_s.end_with?('_ids')
      end
    end
  end
end
