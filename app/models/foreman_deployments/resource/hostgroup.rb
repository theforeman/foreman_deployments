module ForemanDeployments
  module Resource
    class Hostgroup < Abstract
      has_many :parameters, class_name: 'ForemanDeployments::Resource::HostgroupParameter'
      has_many :hosts, class_name: 'ForemanDeployments::Resource::Host'
      has_many :puppetclasses, class_name: 'ForemanDeployments::Resource::PuppetClass'

      validates :name, presence: true
    end
  end
end
