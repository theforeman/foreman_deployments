module ForemanDeployments
  class StackDeployment < ActiveRecord::Base
    extend EnsureAssociationPresent

    self.table_name = ForemanDeployments::TABLE_PREFIX + 'stack_deployments'

    belongs_to :deployment
    belongs_to :stack

    ensure_association_present :deployment
    ensure_association_present :stack
  end
end
