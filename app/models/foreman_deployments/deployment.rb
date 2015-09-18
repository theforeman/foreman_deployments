module ForemanDeployments
  class Deployment < ActiveRecord::Base
    include Authorizable

    belongs_to :configuration, :class_name => 'ForemanDeployments::Configuration', :autosave => true

    validates :name, :presence => true
    validates :configuration, :presence => true

    scoped_search :on => :id, :complete_value => false
    scoped_search :on => :name, :complete_value => :true, :default_order => true

    # TODO: belongs to one organization
    # TODO: optionally belongs to one location

    def stack
      configuration.stack if configuration
    end

    def parsed_stack
      @parsed_stack ||= ForemanDeployments::StackParser.parse(stack.definition) unless stack.nil?
    end
  end
end
