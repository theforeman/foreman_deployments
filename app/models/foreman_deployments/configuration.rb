module ForemanDeployments
  class Configuration < ActiveRecord::Base
    belongs_to :stack, :class_name => 'ForemanDeployments::Stack'
    has_one :deployment, :class_name => 'ForemanDeployments::Deployment'

    validates :stack, :presence => true

    serialize :values, Hash

    def default_description
      if !deployment.nil?
        _('Configuration for %s') % deployment.name
      elsif !stack.nil?
        _('Saved configuration for %s') % stack.name
      end
    end

    def set_config_for(task, config)
      values[task.task_id] = (config || {})
    end

    def get_config_for(task)
      values[task.task_id] || {}
    end
  end
end
