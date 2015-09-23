# Foreman deployments

Foreman deployments plugin allows for defining multi-host provisioning, configuration and orchestration.
There are three main entities accross the whole plugin: **stacks**, **tasks** and **deployments**.


## Stack

*Stack* is an abstract representation of the multi-host infrastructure to be built. They are composed of multiple *tasks* dependent on each other and define
relationships between them. See the "Tasks" section below for the detailed definition of the term.

Same as majority of entities in the Foreman, stacks can be available to multiple organizations and locations.


## Tasks

Tasks are the units a stack is composed of. Each task has defined input parameters and results that it produces. Result of one task can be used as an input
of another one, which enables for setting dependencies.

The stack definition gives a unique name for each of the task instances.

See the list of all [available tasks](writing_stacks.md) and their parameters.


## Stack definition

The stack defines tasks to be used, their inputs and relationships. Task's input can be:
* hardcoded value
* input required form a user in the configuration phase, see list of [available inputs](writing_stacks.md#available-inputs)
* reference to a value from another task
* ignored (default value is used)

Stacks are defined in yaml files.

```yaml
# Following is an example stack definition that creates a new host within a hostgroup

# name of the task
#  |                  task type
#  |                    |
#  ˇ                    ˇ
test_hostgroup: !task:FindResource
  class: test_hostgroup        # <-- task parameters
  search_term: 'name = Test'

test_host: !task:CreateResource
  class: Host
  params:
    hostgroup_id: !reference   # <-- reference to another task's output
      object: test_hostgroup
      field: result.ids.first
    compute_resource_id: 1
    compute_profile_id: 1
    compute_attributes:
      start: '1'
    name: !input:Value         # <-- input entry point
      default: deployment-test
      description: Name for the test host
```

#### Stack's lifecycle

1. Stacks are created as yaml descriptions of the infrastructure. Such yaml file is imported into the Foreman either via API.
1. Modification of imported stacks are allowed up to the point where a first deployment of the stack is created.
1. Stacks can't be deleted in the current release but this feature will be comming soon.


## Deployment

A *deployment* is a result of performing the instructions in a *stack*. It is an instance of a *stack*.

Similar to hosts, deployments belong to a single organization and location.

#### Deployment's lifecycle

1. A deployment is created as a named instance of a stack.
2. Before the deployment can be deployed, it can be configured. Users fill missing parameters in this step.
3. A configured deployment can be deployed onto the Foreman's infrastructure. This step is handled by dynflow.


## Example

A more detailed example is covered in [How to create and deploy a stack](deployment_process.md) section
of our documentation.
