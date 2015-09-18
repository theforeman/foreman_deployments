module ForemanDeployments
  class Stack < ActiveRecord::Base
    include Authorizable

    has_many :configurations, :class_name => 'ForemanDeployments::Configuration'

    validates :name, :presence => true, :uniqueness => true
    validates :definition, :presence => true

    scoped_search :on => :id, :complete_value => false
    scoped_search :on => :name, :complete_value => :true, :default_order => true

    # TODO: add taxonimization
  end
end
