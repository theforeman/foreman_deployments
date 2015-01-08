module ForemanDeployments
  class Deployment < ActiveRecord::Base
    include Authorizable
    include Taxonomix

    self.table_name = 'foreman_deployments_deployments'
    scoped_search :on => :name, :complete_value => :true
  end
end
