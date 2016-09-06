module ForemanDeployments
  class StackParseException < ::Foreman::Exception; end
  class UnknownTaskException < StackParseException; end
  class UnknownYAMLTagException < StackParseException; end
  class UnknownReference < StackParseException; end

  class ReferenceVisitor
    def initialize
      @references = []
    end

    def visit(subject)
      if subject.is_a? ForemanDeployments::TaskReference
        save_reference(subject)
      elsif subject.is_a? ForemanDeployments::StackDefinition
        link_references(subject)
      end
    end

    def save_reference(reference)
      @references << reference
    end

    def link_references(stack_definition)
      @references.each do |ref|
        task = stack_definition.tasks[ref.task_id]
        if task.nil?
          fail(UnknownReference, _('%s references unknown task') % ref.task_id)
        else
          ref.task = task
        end
      end
    end
  end

  class StackParser
    TAG_DOMAIN = 'deployments.theforeman.org,2015'.freeze

    def initialize(registry = nil)
      @registry = registry || ForemanDeployments.registry
    end

    def parse(stack_definition)
      stack_definition = prepare_stack(stack_definition)

      begin
        parsed_stack = SafeYAML.load(stack_definition.to_s, nil,
                                     :whitelisted_tags => init_whitelisted_tags,
                                     :raise_on_unknown_tag => true)
      rescue RuntimeError => e
        raise wrap_exception(e)
      end

      unless parsed_stack.is_a? Hash
        fail(StackParseException, _('Stack definition is invalid'))
      end

      definition = ForemanDeployments::StackDefinition.new(parsed_stack)
      definition.accept(ReferenceVisitor.new)
      definition
    end

    def self.parse(stack_definition)
      StackParser.new.parse(stack_definition)
    end

    private

    def init_whitelisted_tags
      whitelist = [domain_prefix('reference')] # WARNING: safe_yaml behaves differently when the whitelist is empty
      YAML.add_domain_type(TAG_DOMAIN, 'reference') do |_tag, params|
        TaskReference.new(params['object'], params['field'])
      end

      @registry.available_tasks.each do |task_name, task_class|
        whitelist << task_prefix(task_name)
        YAML.add_domain_type(TAG_DOMAIN, 'task:' + task_name) do |_tag, params|
          task_class.constantize.build(params)
        end
      end

      @registry.available_inputs.each do |input_name, input_class|
        whitelist << input_prefix(input_name)
        YAML.add_domain_type(TAG_DOMAIN, 'input:' + input_name) do |_tag, params|
          input_class.constantize.build(params)
        end
      end
      whitelist
    end

    def prepare_stack(stack_definition)
      "%TAG ! #{domain_tag}\n---\n#{stack_definition}"
    end

    def domain_tag
      "tag:#{TAG_DOMAIN}:"
    end

    def domain_prefix(name = '')
      "#{domain_tag}#{name}"
    end

    def task_prefix(task_name = '')
      domain_prefix("task:#{task_name}")
    end

    def input_prefix(input_name = '')
      domain_prefix("input:#{input_name}")
    end

    def wrap_exception(e)
      if e.message =~ /Unknown YAML tag '#{task_prefix}([^']+)/
        UnknownTaskException.new(_('Unknown stack task %s') % Regexp.last_match[1])
      elsif e.message =~ /Unknown YAML tag '#{domain_tag}([^']+)/
        UnknownYAMLTagException.new(_('Unknown YAML tag %s') % Regexp.last_match[1])
      else
        e
      end
    end
  end
end
