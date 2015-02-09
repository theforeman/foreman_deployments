module ForemanDeployments
  class Stack < ActiveRecord::Base
    include Authorizable
    include Taxonomix
    # TODO validate taxonomy, in parent context, it has to be the same something like that
    # TODO add child resource to be able to compose stacks

    self.table_name = ForemanDeployments::TABLE_PREFIX + 'stacks'

    has_many :resources,
             class_name: 'ForemanDeployments::Resource::Abstract',
             dependent: :destroy
    has_many :deployments, :through => :stack_deployments

    has_many :stack_deployments # private

    scoped_search :on => :name, :complete_value => :true
    validates :name, :presence => true

    def configurable_resources
      Resource::Abstract.reduce_configuration_order { |resource_class| resource_class.configurable(self) }
    end
  end
end
