module ForemanDeployments
  module Resource
    class Abstract < ActiveRecord::Base
      extend EnsureAssociationPresent

      self.table_name = 'foreman_deployments_resources'

      belongs_to :stack, :class_name => 'ForemanDeployments::Stack'
      ensure_association_present :stack

      validates :name, :presence => true

      scoped_search :on => :name, :complete_value => :true
    end
  end
end
