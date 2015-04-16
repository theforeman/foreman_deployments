module ForemanDeployments
  module Resource
    class PuppetClass < Abstract
      belongs_to :hostgroup, class_name: 'ForemanDeployments::Resource::Hostgroup'
      ensure_association_present :hostgroup
      has_many :parameter_overrides, class_name: 'ForemanDeployments::Resource::ParameterOverride'

      validates :name, presence: true
    end
  end
end
