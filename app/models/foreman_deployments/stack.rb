module ForemanDeployments
  class Stack < ActiveRecord::Base
    include Authorizable
    include Taxonomix

    has_many :configurations, :class_name => 'ForemanDeployments::Configuration'

    validates :name, :presence => true, :uniqueness => true
    validates :definition, :presence => true

    attr_accessible :name, :definition

    scoped_search :on => :id, :complete_value => false
    scoped_search :on => :name, :complete_value => :true, :default_order => true

    default_scope do
      with_taxonomy_scope do
        order('stacks.name')
      end
    end
  end
end
