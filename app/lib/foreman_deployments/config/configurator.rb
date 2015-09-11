module ForemanDeployments
  module Config
    class Configurator
      def initialize(stack_definition)
        @stack_definition = stack_definition
      end

      def configure(configuration)
        ForemanDeployments::Config::LoadVisitor.load(@stack_definition, configuration)
      end

      def merge(*configurations)
        configurations.each do |c|
          ForemanDeployments::Config::MergeVisitor.merge(@stack_definition, c)
        end
      end

      def dump(configuration)
        ForemanDeployments::Config::SaveVisitor.save(@stack_definition, configuration)
      end
    end
  end
end
