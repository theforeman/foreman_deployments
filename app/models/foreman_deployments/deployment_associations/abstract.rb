module ForemanDeployments
  module DeploymentAssociations
    class Abstract < ActiveRecord::Base
      self.abstract_class = true

      extend EnsureAssociationPresent
      extend Algebrick::TypeCheck

      def self.define_association(foreman_class, resource_class)
        Child! resource_class, Resource::Abstract

        underscored_name = foreman_class.to_s.underscore
        self.table_name  = ForemanDeployments::TABLE_PREFIX + 'assoc_' + to_s.demodulize.underscore.pluralize

        belongs_to :deployment, class_name: 'ForemanDeployments::Deployment'
        belongs_to :resource, class_name: resource_class.to_s
        belongs_to underscored_name.to_sym, class_name: "::#{foreman_class}"

        ensure_association_present :deployment
        ensure_association_present :resource
        ensure_association_present underscored_name.to_sym
      end
    end
  end
end
