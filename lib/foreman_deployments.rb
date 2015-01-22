require "algebrick"

require "foreman_deployments/engine"

module ForemanDeployments

  TABLE_PREFIX = 'FD_'

  # temporary method to create sample Stack
  # TODO remove
  def self.create_test_stack
    stack = Stack.new name: 'db'

    stack.resources.push(
        hostgroup = Resource::Hostgroup.new(name: 'db'),
        Resource::HostgroupParameter.new(
            name:      'password',
            stack:     stack,
            hostgroup: hostgroup),
        Resource::HostgroupParameter.new(
            name:      'url',
            stack:     stack,
            hostgroup: hostgroup,
            # TODO replace pseudo
            value:     '<%= compute_url() %>'),
        postgeress_module = Resource::PuppetClass.new(
            name:      'postgres',
            stack:     stack,
            hostgroup: hostgroup),
        Resource::ParameterOverride.new(
            name:         '$postgress::password',
            # TODO replace pseudo
            value:        "<%= get_param('db', 'db_hostgroup', 'db_password') %>",
            stack:        stack,
            puppet_class: postgeress_module),
        host = Resource::Host.new(
            name:      'db-%3d',
            min:       1,
            max:       1,
            hostgroup: hostgroup,
            stack:     stack),
        run1 = Resource::PuppetRun.new(
            host:  host,
            stack: stack),
        run2 = Resource::PuppetRun.new(
            host:  host,
            stack: stack)
    )

    run1.depends_on.push run2

    stack.save!
    stack
  end

  # FIXME turn this into tests!
  def self.test_config
    stack      = create_test_stack
    deployment = Deployment.create! name: "deploy-#{stack.name}-#{rand(100)}", stack: stack

    hostgroup_resource = deployment.configurable_resources[Resource::Hostgroup].first
    deployment.configure_resource hostgroup_resource, ::Hostgroup.find_by_name('base')

    values = { 'password' => 'secret', 'url' => 'example.com:5432' }
    deployment.configurable_resources[Resource::HostgroupParameter].each do |hostgroup_parameter_resource|
      deployment.configure_resource hostgroup_parameter_resource, values.fetch(hostgroup_parameter_resource.name)
    end

    [deployment.configurable_resources, # all
     deployment.configured_resources, # all
     deployment.not_configured_resources, # empty
     deployment.configuration_phase] # nil no more phase to configure
  end
end

FD = ForemanDeployments # TODO remove, just shortcut for rails console
