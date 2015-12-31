module ForemanDeployments
  class Deployment < ActiveRecord::Base
    include Authorizable
    include ForemanDeployments::Concerns::BelongsToStackTaxonomy

    belongs_to :configuration, :class_name => 'ForemanDeployments::Configuration', :autosave => true
    belongs_to :task, :class_name => 'ForemanTasks::Task'

    validates :name, :presence => true
    validates :configuration, :presence => true

    attr_accessible :name, :configuration, :task

    scoped_search :on => :id, :complete_value => false
    scoped_search :on => :name, :complete_value => true, :default_order => true

    def stack
      configuration.stack if configuration
    end

    def parsed_stack
      @parsed_stack ||= ForemanDeployments::StackParser.parse(stack.definition) unless stack.nil?
    end

    def configurator
      @configurator ||= ForemanDeployments::Config::Configurator.new(parsed_stack)
    end

    def run
      fail(Foreman::Exception, _("You can't start a deployment that is already running!")) if status == :running

      # configure with user input
      configurator.configure(configuration)

      # validate
      parsed_stack.validate!

      self.task = ForemanTasks.async_task(Tasks::StackDeployAction, parsed_stack)
      save
    end

    def status
      # configuration, running, deployed, failed
      if task.nil?
        :configuration
      elsif task.state == 'paused'
        :paused
      elsif task.state == 'stopped'
        if task.result == 'success'
          :deployed
        else
          :failed
        end
      else
        :running
      end
    end
  end
end
