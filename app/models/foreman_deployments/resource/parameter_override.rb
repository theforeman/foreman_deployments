module ForemanDeployments
  module Resource
    class ParameterOverride < Abstract
      # overrides in
      belongs_to :puppet_class, class_name: 'ForemanDeployments::Resource::PuppetClass'
      ensure_association_present :puppet_class

      validates :name, presence: true
      # validates :value
      # TODO does Parameter has a type defined? can be inferred later when deployment is configured
    end
  end
end
