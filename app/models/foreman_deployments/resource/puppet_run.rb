module ForemanDeployments
  module Resource
    class PuppetRun < Abstract
      include Ordered

      belongs_to :host, class_name: 'ForemanDeployments::Resource::Host'
      ensure_association_present :host
    end
  end
end
