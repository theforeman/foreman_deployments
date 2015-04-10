# User interfaces


## 3 Ways of creating a deployment:
- by deploying a stack
  - every stack is deployable
  - the UI path: `stack list` → select stack & click `[Deploy]` → `deployment creation form` → click `[Configure]` → `deployment config form` → click `[Deploy]` → `deployment info`
- by deploying a configuraion
  - an existing configuration is cloned and used for the new deployment (not all values are clonable, e.g. bare metal hosts)
  - the path: `stack's config list` → select config & click `[Deploy]` → `deployment creation form` → click `[Configure]` → `deployment config form` with cloned values, fields that are not clonable are blank → click `[Deploy]` → `deployment info`
- by cloning an existing deployment
  - technically the same as deploying a configuration, different only from the user's perspective
  - the path: `deployment list` → select config & click `[Clone]` → `deployment creation form` → `[Configure]` → `deployment config form` with cloned values, fields that are not clonable are blank → `[Deploy]` → `deployment info`


## UI pages

### List of stacks
- shows all stacks imported into foreman
- the list contains
  - stack name
  - number of existing deployments (link to list of the deployments filtered by search)
  - row action buttons:
    - `deploy` - leads to the deployment creation form
    - `configure` - leads to config form, result is saved as a separate config for future cloning
    - `configurations` - leads to the list of existing configurations
    - `export`
    - `delete` - disabled if it's already deployed
- top buttons:
  - `import stack`

### Stack info
- shows info about used tasks, required puppet classes, subnets etc.
- top buttons:
  - `deploy` - leads to the deployment creation form
  - `configure` - leads to config form, result is saved as a separate config for future cloning
  - `export`
  - `delete` - disabled if it's already deployed


### List of stack configurations
- shows all stack configurations
- the list contains
  - name of the configuration
  - what stack is that for
  - what deployment was that for (only if it's not a saved config template)
  - row action buttons:
    - `deploy` - leads to the deployment creation form
    - `delete` - only for configurations that have no deployment assigned
    - `details` - list of all configuration values
- top buttons:
  - NONE


### List of existing deployments
- shows all created deplyments
- the list contains
  - name of the deployment
  - phase of the deployment (created/configured/deploying/deployed)
  - number of hosts in the stack (link to list of the hosts filtered by search)
  - row action buttons:
    - `configure` - leads to the deployment creation form, shown only if the configuration is not finished yet
    - `delete`
- top buttons:
  - NONE


### Import stack form
- select file field
- below buttons:
  - `cancel`
  - `import` - successful import leads to the list of stacks


### Deployment creation form
- name for the deployment
- list of select boxes for abstract substacks (name, description from the ChildStackTask should be shown here to explain)
- select box for existing configuration (probably dependent on the combination of concrete substacks)
- below buttons:
  - `cancel`
  - `create` - leads to config form


### Deployment configuration form
- displays field for configuration name (is prefilled with some meaningful value or hidden in case of deploying without preset config)
- shows configuration partials for tasks that need some users inputs
- parials are shown in the order from the stack definition

- below buttons:
  - `save`
  - `deploy`
  - `cancel`


### Deployment info
- progressbar is shown, waits until all hosts are provisioned and configured.
- can show progress of the single actions
- link to dynflow console
- below buttons:
  - `cancel`/`back`


## CLI interactions
Mimics the UI interactions.

List available stacks
```bash
hammer stack list
```

Import a new stack from a file
```bash
hammer stack import --name "Web Server Stack" --file "web_server.json"
```

Json export of existing stacks
```bash
hammer stack export --name "Web Server Stack"
```

Get details about a stack
```bash
hammer stack info --name "Web Server Stack"
```

List all deployments of a stack
```bash
hammer stack deployments --name "Web Server Stack"
```

List saved configurations and deployments' configurations
```bash
hammer stack configurations --name "Web Server Stack"
```

List all existing deployments, filterable by stacks
```bash
hammer deployment list [--stack "Web Server Stack"]
```

Create a deployment of a stack. Users can optionally pass a saved config
```bash
hammer deployment create --stack "Web Server Stack" --name "Web Server Instance" [--configuration "My saved config"]
```
Assignment of concrete stacks will be available in future
```bash
hammer deployment create --stack "Web Server Stack" --name "Web Server Instance" [--configuration "My saved config"] --stacks="db=mysql,gallery=phoca"
```

Get details about a deployment. It shows state of the deployment and configuration values too
```bash
hammer deployment info --name "Web Server Instance"
```

Configure the deployment parameters. Values can be saved either all at once or one by one. There are multiple ways of implementing this

**TODO**: *solve how to send structured values like nics*

1) Mapping config to key-value pairs
```bash
hammer deployment configure --name "Web Server Instance" --values "db_passwd=xxx,db_user=webapp"
```
2) Always specify the task one configures as a full dot separated path
```bash
hammer deployment configure --name "Web Server Instance" --task "db" --values "count=1,compute_resource=libvirt"
```
```bash
hammer deployment configure --name "Web Server Instance" --task "db.nics" --values "count=1"
```
3) Always send a json
```bash
hammer deployment configure --name "Web Server Instance" --values "{'db': {'count': 1, 'nics': [ ... ]}}"
```

Start the deployment process
```bash
hammer deployment deploy --name "Web Server Instance"
```

Clone a deployment. Creates a deployment with the cloned configuration. Should notify user whether there are some blank values that need additional attention.
```bash
hammer deployment clone --name "Web Server Instance" --new-name "Second Web Server Instance"
```

Deploy the cloned deployment.
```bash
hammer deployment deploy --name "Second Web Server Instance"
```

