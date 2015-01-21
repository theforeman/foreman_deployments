module ForemanDeployments
  module Resource
    class Dependency < ActiveRecord::Base
      extend EnsureAssociationPresent

      self.table_name = ForemanDeployments::TABLE_PREFIX + 'resource_dependencies'

      belongs_to :depended_by, class_name: 'ForemanDeployments::Resource::Abstract', foreign_key: 'depended_by_id'
      belongs_to :depends_on, class_name: 'ForemanDeployments::Resource::Abstract', foreign_key: 'depends_on_id'

      ensure_association_present :depended_by
      ensure_association_present :depends_on
      after_save :ensure_ordered_instances

      def ensure_ordered_instances
        raise unless [depended_by, depends_on].all? { |e| e.is_a? Ordered }
      end
    end
  end
end
