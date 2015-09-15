module ForemanDeployments
  module Tasks
    class WaitUntilBuiltTaskDefinition < ForemanDeployments::Tasks::BaseDefinition
      class Action < BaseAction
        include Dynflow::Action::Polling

        def done?
          external_task['built'] == true
        end

        def timeout
          input['timeout'] || 2 * 60 * 60 # 2 hours default
        end

        def invoke_external_task
          schedule_timeout(timeout) unless timeout <= 0
          WaitUntilBuiltTaskDefinition.build_status
        end

        def poll_external_task
          # TODO: check the case when no host_id is sent
          host = Host.find(input['host_id'])
          WaitUntilBuiltTaskDefinition.create_output(host, output)
          WaitUntilBuiltTaskDefinition.build_status(host)
        end

        def poll_interval
          30
        end
      end

      def validate
        ValidationResult.new
      end

      def preliminary_output(_parameters)
        WaitUntilBuiltTaskDefinition.create_output(Host::Managed.new)
      end

      def dynflow_action
        ForemanDeployments::Tasks::WaitUntilBuiltTaskDefinition::Action
      end

      def self.create_output(host, output_hash = {})
        output_hash['object'] = host
        output_hash['object']['facts'] = host.facts
        output_hash
      end

      def self.build_status(host = nil)
        status = (!host.nil? && (host.reports.count > 1) && !host.reports.last.error?)
        { 'build' => status }
      end

      def self.tag_name
        'WaitUntilBuilt'
      end
    end
  end
end
