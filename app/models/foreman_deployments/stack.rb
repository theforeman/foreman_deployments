module ForemanDeployments
  class Stack < ActiveRecord::Base
    include Authorizable
    include Taxonomix
    # TODO validate taxonomy, in parent context, it has to be the same something like that
    # TODO add child resource to be able to compose stacks

    self.table_name = 'foreman_deployments_stacks'

    validates :name, :presence => true

    scoped_search :on => :name, :complete_value => :true
  end
end
