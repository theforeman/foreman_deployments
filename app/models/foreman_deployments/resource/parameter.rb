module ForemanDeployments
  module Resource
    class Parameter < Abstract
      # TODO add human readable name and description

      has_many :updates, class_name: 'ForemanDeployments::Resource::ParameterUpdate'
      validates :name, presence: true
      # validates :value
    end
  end
end
