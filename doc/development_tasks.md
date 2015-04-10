# POC

-   stack definition
-   TODOs in <https://github.com/theforeman/foreman_deployments/pull/1>
* deployed hosts are marked in the UI, they hold link to their deployment

-   configuration resources
    -   resource configuration API
        -   **basic array attribute configuration and retrieval**
        -   configuration description meta data
        -   configure resources by `Hash`
    -   hammer commands for the API points
        -   deployment (create, deploy)
        -   resource (only query)
        -   stack (delete) (create by custom script using AR directly)
    -   resources
        -   **host**
        -   **hostgroup**
        -   **hostgroup_parameter**
        -   puppetclass
        -   param_override

-   deployment configuration

-   orchestration
    -   abstract Ordering resources (API to provide the Dynflow action)
    -   provision hosts (compute_resource only)
    -   run ordered resources
        -   puppetrun_resource
        -   param_update
    -   reenable puppet_run

# Technical preview

-   configuration resources
    -   resources
        -   child_resource
        -   connection_resource
        -   compute_resource
        -   deployment_parameter_resource
    -   hammer commands for the API points
        -   deployment (delete)
        -   stack (import, export)

-   UI
    -   configuration wizard
    -   deployments
    -   configurations
    -   stacks
    -   links in hosts and hostgroups to deployments

-   stack DSL, YAML export formats

# Production ready

-   configuration resources
    -   resources
        -   compute_profile
        -   subnet_type_resource
        -   interface_resource ?

-   stack DSl in UI, safe evaluation in sandbox

# Use-cases

-   be able to re-use existing hosts, bare-metal, compute_resource
-   HA OpenStack controllers (Lead and rest)
-   IP reservation for OpenStack (InterfaceResource)

# Requirements

-   hosts has to have disabled periodic puppet_runs



=============================================================================================================

Priloha: TODOs

TODOs

    add dependent destroy directives
        use katello test to find all the associations without the option defined
    add scoped search to the models
    add foreign keys
    take puppetssh from staypuft
    look into parameters to be able to define special value 'inherited' (similar to css)

Missing resource and/or its configuration implementations

    puppet class
    parameter override
    child resource
    ...

API including CLI commands

    configuration on deployment create
        and as an extra call
    query configurable resources of a stack or include in show

Integration

    show deployment association in the hostgroup table
    ...
    figure out other integrations in UI

@pitr-ch:

    host resource configuration
    orchestration mock for one host
    start building deployment orchestration

Later

    design: stack inheritance may be unavoidable for reusability





