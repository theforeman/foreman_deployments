module ForemanDeployments
  module Resource
    class ParameterOverride < Abstract
      # overrides in
      belongs_to :puppetclass, class_name: 'ForemanDeployments::Resource::Puppetclass'
      ensure_association_present :puppetclass

      validates :name, presence: true
      # validates :value
      # TODO does Parameter has a type defined? can be inferred later when deployment is configured
    end
  end
end
