module ForemanDeployments
  class Stack < ActiveRecord::Base
    include Authorizable
    include Taxonomix

    # TODO(pchalupa) probably better to use acyclic graph, use EnsureNoCycle
    # TODO(pchalupa) validate taxonomy, in parent context, it has to be the same something like that

    belongs_to :parent, :class_name => 'Stack'
    has_many :children, :class_name => 'Stack', :foreign_key => 'parent_id'

    validates :name, :presence => true

    scoped_search :on => :name, :complete_value => :true
  end
end
