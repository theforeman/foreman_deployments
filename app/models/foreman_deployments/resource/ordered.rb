module ForemanDeployments
  module Resource
    module Ordered
      extend ActiveSupport::Concern

      included do
        has_many :depended_by,
                 through:    :depended_by_dependency,
                 class_name: 'ForemanDeployments::Resource::Abstract'

        has_many :depends_on,
                 through:    :depends_on_dependency,
                 class_name: 'ForemanDeployments::Resource::Abstract'

        # private
        has_many :depended_by_dependency,
                 class_name:  'ForemanDeployments::Resource::Dependency',
                 foreign_key: 'depend_on_id'

        has_many :depends_on_dependency,
                 class_name:  'ForemanDeployments::Resource::Dependency',
                 foreign_key: 'depended_by_id'
      end
    end
  end
end
