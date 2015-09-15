module ForemanDeployments
  class Stack < ActiveRecord::Base
    has_many :configurations, :class_name => 'ForemanDeployments::Configuration'

    validates :name, :presence => true, :uniqueness => true
    validates :definition, :presence => true

    # TODO: add taxonimization
  end
end
