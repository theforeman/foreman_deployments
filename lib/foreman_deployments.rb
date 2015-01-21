require "algebrick"

require "foreman_deployments/engine"

# TODO add dependent destroy directives, use katello test to find all the associations without the option defined

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
            hostgroup: hostgroup),
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

  def self.test_config
    stack              = create_test_stack
    deployment         = Deployment.create! name: Time.now.to_s, stack: stack
    hostgroup_resource = deployment.configurable_resources[Resource::Hostgroup][0]
    deployment.configure_resource hostgroup_resource, ::Hostgroup.find_by_name('base')

    sleep 0.1

    pp deployment.configurable_resources
    pp deployment.configured_resources
    nil
  end
end

FD = ForemanDeployments
