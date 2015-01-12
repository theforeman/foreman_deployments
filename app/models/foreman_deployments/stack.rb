module ForemanDeployments
  class Stack < ActiveRecord::Base
    include Authorizable
    include Taxonomix
    # TODO validate taxonomy, in parent context, it has to be the same something like that
    # TODO add child resource to be able to compose stacks

    self.table_name = 'foreman_deployments_stacks'

    has_many :resources,
             class_name: 'ForemanDeployments::Resource::Abstract',
             dependent: :destroy

    scoped_search :on => :name, :complete_value => :true
    validates :name, :presence => true
  end
end
