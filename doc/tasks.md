## Tasks


#### RunPuppetTask
Triggers a puppetrun on a host or group of them.

* inputs:
  * host_id(s)

#### EnablePuppetTask
Enable/disable periodic puppet runs on a host or group of them.

* inputs:
  * host_id(s)
  * enable (flag saying whether to enable or disable puppet)

#### ProvisionHostTask
Starts provisioning of a host or group of them.

* inputs:
  * host_id(s)

#### ParameterUpdateTask
Updates a parameter on a hostgroup, host or group of them.

* inputs:
  * parameter
  * host_id(s)
  * hostgroup_id(s)

#### RemoteExecutionTask
Execute custom code on a host or group of them.

* inputs:
  * execution provider
  * host_id(s)

#### SelectResourceTask
Select an existing resource from the Foreman.

* limited only to resources that have scoped search defined on them
* allows for defining query that limits the selection
* inputs:
  * preselected resource id (can be used as default)
* output:
  * the resource's id

#### CreateResourceTask
Creates a Foreman resource. Eventually it should be possible to create any resource inside Foreman.

We're currently evaluating the posibilities of re-using the existing UI partials for this task's configuration.

It will be possible to specify a range of how many resources of such type should be created. This is useful mainly for hosts
where one sometimes wants to create multiple hosts with the same configuration. In such case, the host name will be configured
to a template "#{name}-#{index}" by default.

* inputs:
  * attributes for the resource
  * range for the number of resources (mainly for hosts)
* output:
  * the resource's id

Alternatively we can create a dedicated task for each resource type.

#### SelectOrCreateResourceTask
Shows configuration UI of the select task but allows for switching into creation mode
and adding new resource.

* encapsulates `SelectResourceTask` and `CreateResourceTask` into one
* inputs:
  * select task (and it's configuration)
  * create task (and it's configuration)
* output:
  * the resource's id
