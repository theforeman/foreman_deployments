# How to write a stack

Stacks are defined in [yaml](http://yaml.org) format. Foreman deployments provide set of custom
yaml tags for specifying tasks, references between them and inputs.

Stack definition can contain only `task name` -> `task definition` pairs.
Inner structure of the task definition varies according to the task type.

```yaml
uniqe_task_name: !task:TaskType
  parameters:
    some: values
```

## Available tasks

### CreateResource
Creates a resource in the Foreman including hosts.

```yaml
example: !task:CreateResource
  class: Host # The foreman resource to create
  params:     # Hash of parameters for the resource
    # ...
```
**Output:**
```yaml
object:
  # hash of the host's parameters including facts
  # ...
```

### FindResource
Find resources by the scoped search filter.

```yaml
example: !task:FindResource
  class: Hostgroup           # The foreman resource to search for
  search_term: 'name = Test' # Scoped search filter, same syntax as in the UI Search field
```
**Output:**
```yaml
results:
    # array of the found resources
    # ...
result:
    ids:     # array of resources' ids
        - 1
        - 2
```

### WaitUntilBuilt
Waits until a host is provisioned and reports successfully.

```yaml
example: !task:WaitUntilBuilt
  timout: 3600           # In seconds, default is 3 hours
  host_id: !reference    # Id fo a host to wait for,
    object: host_x       # usually passed as a reference to a host creation task
    field: object.id

```
**Output:**
```yaml
task:
  build: true/false # has the host been built yet?
object:
  # hash of the host's parameters including facts
  # ...
```

## Available inputs

Currently there's only one input type.
More input types including some validation capabilities will be implemented in future.

### Value
Marks the parameter as an input entry point for users. It allows to
provide a description and a default value.

```yaml
example: !task:SomeTask
  name: !input:Value
    default: test-deployment-foreman
    description: Name for the foreman host
```

## Ordering actions without direct dependency

Even though dynflow engine calculates the task dependencies automatically,
there might be cases when a stack writer needs to put hard order between two
tasks that don't directly depend on each other. In such situations a reserved
field `after` can be used:

```yaml
FirstTask: !task:SomeTask

SecondTask: !task:SomeTask
  after: !reference
    object: 'FirstTask'
    field: 'result'
```
