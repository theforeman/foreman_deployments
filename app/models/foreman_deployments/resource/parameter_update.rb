module ForemanDeployments
  module Resource
    class ParameterUpdate < Abstract
      include Ordered

      belongs_to :parameter, class_name: 'ForemanDeployments::Resource::Parameter'
      ensure_association_present :parameter

      validates :value, presence: true
    end
  end
end
