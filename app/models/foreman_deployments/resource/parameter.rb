module ForemanDeployments
  module Resource
    class Parameter < Abstract
      has_many :updates, class_name: 'ForemanDeployments::Resource::ParameterUpdate'
      validates :name, presence: true
      # validates :value
    end
  end
end
