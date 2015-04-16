# Design


This design document describes the concept of multi-host orchestration in the Foreman.

![Overview diagram](./diagrams/overview_class.png)

## Stack

Stack is an abstract representation of the multi-host infrastructure to be built. They are composed of "resources" and define relationships between them. An example resource is host, hostgroup, puppet class, etc. See the "Resource" section below for the detailed definition of the term.

Stacks are designed to be independent of the Foreman instances and therefore they allow for being shared. The ultimate goal is being able to import a stack that has been created elswhere into your Foreman instance and deploy it on our infrustructure. User inputs and mapping to the Foreman objects take place in the configuration phase of the deployment. All inputs are defined by the "resources".

Same as majority of entities in the Foreman, stacks can belong to multiple organizations and locations.


#### Nesting the stacks

Apart from usual resources, a stack can define usage of another existing stack. User can for example define a "Web app stack" that is composed of a "Database stack" and a "Web server stack".

#### Stack abstraction

It is possible to define an abstract stack that can't be deployed. Such stacks require their concrete implementations, that fulfill [The Liskov substitution principle](http://en.wikipedia.org/wiki/Liskov_substitution_principle).

E.g. a "Web app stack" could be defined as composition of "Abstract DB stack" and "Abstract server stack". This needs to be substituted by concrete implementations (e.g. "Sinatra stack" and "Mongo DB stack") upon a deployment creation.

This feature will not be part of the first implementation.

#### Stack inheritance

Stacks can inherit properties from their parents. All parent resources and their associations are then also part of child stacks. Child stack can add new resources, but no updates or removals are allowed. Child resource may depend on resource from parent stack.

Example use case can be abstract DB stack and its implementations where inheritance makes the implementation easier.

This feature will not be part of the first implementation.


#### Stack definition

Stacks are defined in json files. See [implementation details](implementation.md#stack-definition) for more information.


#### Stack's lifecycle

1. Stacks are created as json descriptions of the infrastructure. Such json file is imported into the Foreman either via UI or API.
   Json is the only supported import format. We can create conversion tools from a dedicated DSL to the json for the users' convenience
1. Modification of imported stacks is not enabled. If the json definition is changed, users must import it again as a new stack.
1. Stacks can be deleted only when there's no existing deployment of them. The removal action deletes the stack, it's resource definition and configurations.


## Resource

Resources are the units a stack is composed of. There are two types of resources. This split is only on the model level. Users that define the stacks won't
see much difference:

1. **configuration resource**
  * define foreman objects to be created, configured, or used (e.g. subnet, hostgroup)
  * may require user's inputs in the deployment configuration phase, they keep configuration order for the means of building the UI
  * they are processed before the actual deployment starts (before provisioning and execution of ordered resources)
1. **ordered resource**
  * orchestration actions that need to happen in certain order (e.g. puppetrun, set parameter)
  * from the user's perspective the only difference is they can assign order to this kind of resource

See [list of resources](resources.md) for details about available resources.

**NOTE:** *Since we now have the configuration separate from the resources, it is possible to merge the two types and make the model easier to understand for developers.*


## Deployment

A "deployment" is a result of performing the instructions in a "stack". It is an instance of a "stack",
where we can record the exact Foreman objects that have been used.

Similar to hosts, deployments belong to a single organization and location.

#### Deployment's lifecycle

1. A deployment is created as a named instance of a stack.
2. Before the deployment can be deployed, it needs to be configured. Users fill missing parameters in this step and assign Foreman's resources like hostgroups and subnets.
More on this step later.
3. A configured deployment can be deployed onto the Foreman's infrastructure. This step is handled by dynflow. See [implementation details](implementation.md).
4. A deployment record(s) can be deleted while the deployed hosts keep on running. Although they save links to Foreman objects, deployments are separate from them.
Deleting associated hosts and hostgroups together with the deployment can be added as a future feature.



## Deployment configuration

Deployment configuration holds set of user's inputs and mapping on the Foreman instance's objects. For example
what parent usergroups should be used, mapping of subnets, number of hosts and their configuration (nics).

Configuration is always instance specific. It is kept separate from the deployments to enable saving pre-configurations and cloning of existing deployments.

Pre-configurations are saved without foregin key to any deployment. Users can clone and create a new deployment based on the saved config.
Unclonable fields like mac addresses are blanked and users need to replace them with new values. In certain circumstances this enables one click deployments.

The saved configuration consists of pieces belonging to individual resources. Each piece is saved into DB as an exported json. Resources
provide classes responsible for interpreting and saving the config.


## Platform details and integration with Katello

Puppet master, proxy, environment and platform details like os, media, config templates are going to be set
via parent hostgroup of the deployment's hostgroups.

Integration with Katello will be done the same way via activation keys.




## The basic deployment workflow
1. stack definition
  * the user writes the json definition and imports it into the foreman → new stack is created
1. deployment creation
  * user selects the stack to deploy and gives the deployment a name
  * if the stack uses any child abstract stack the user must select concrete implementation for each of them
    (e.g. DB stack can be either Postgres or MySQL)
2. deployment configuration
  * the user can select an existing deployment configuration → fields are prepopulated → he/she can change them accoridng to needs
  * configuration resources are presented as fields in their order (given by the resource class)
  * new configuration is saved
2. deploying the deployment
  * when the configuration is finished the user can start deploying
  * at first configuration resources are created in the Foreman
  * then hosts are provisioned with disabled puppet
  * next the ordered resources (actions) are executed
  * puppet is enabled on all hosts as a very last step, cfgmgmt layer selects how to enable it


## Compatibility issues

Some stacks might not be applicable to all operating systems, for example because of incompatibility of the used puppet classes.
We will solve this by description of the stack (descriptions are shown to user during deployment configuration and creation).
There are no plans to implement any kind of such compatibility checks in the first phase. We can later implement it via some kind
of restriction resource or via adding more features to a hostgroup resource.



