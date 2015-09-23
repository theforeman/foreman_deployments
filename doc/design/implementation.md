# Implementation details


## Stack definition
* defined in a simple json
* the structure is currently very flat, we should think of something more nested to avoid repeating the foreign keys
* example stack definition:
```
{
  "stacks": [
    {
      "id": "db",
      "name": "db"
    }
    // other stacks
  ],
  "param_resources": [
    {
      "id": "db_password",
      "stack": "db",
      "name": "db_password",
      "hostgroup_resource": "db"
    },
    {
      "id": "db_api_url",
      "stack": "db",
      "name": "db_api_url",
      // pseudo code, computes the url for other stacks to use
      "default_value": "<%= compute_url() %>",
      "hostgroup_resource": "db"
    }
  ],
  "param_override_resources": [
    {
      "id": "password_override",
      "stack": "db",
      "name": "password_override",
      "key": "$postgress::password",
      // just pseudo code
      "value": "<%= get_param('db', 'db_hostgroup', 'db_password') %>",
      "hostgroup_resource": "db"
    }
  ],
  "hostgroup_resources": [
    {
      "id": "db",
      "stack": "db"
    }
  ],
  "host_resources": [
    {
      "id": "db",
      "stack": "db",
      "min": 1,
      "max": 1,
      "hostgroup_resource": "db"
    }
  ],
  "puppet_class_resources": [
    {
      "id": "postgres",
      "name": "postgres",
      "stack": "db",
      "hostgroup_resource": "db"
    }
  ],
  "puppet_run_resources": [
    {
      "id": "db1",
      "host_resource": "db"
    },
    {
      "id": "db2",
      "host_resource": "db",
      "depends_on": "db1"
    }
  ]
}
```
* DSL conversion tool can be created, example dsl:
```ruby
require 'foreman/deployments/dsl'

Foreman::Deployments::DSL.define do
  stack :db do
    hostgroup :db do
      param :db_password
      param(:db_api_url) { default_value "<%= compute_url() %>" }
      override :password_override do
        name "password_override"
        key "$postgress::password"
        value "<%= get_param('db', 'db_hostgroup', 'db_password') %>"
      end
      puppetclass :postgres
    end

    host :db do
      count 1..1
      puppet_run(:db1) >> puppet_run(:db2)
    end
  end
end
```

## Deployment
* resources implemented as STI

## Deployment configuration
* belongs to stack and deployment (the second can be nil when it is saved preconfiguration)
* can be implementad as STI or as filters that only synthesize hash to json
* configurable resources provide their ResourceConfig class
* each ResourceConfig defines how to clone itself (blanking fields that are not clonable)

## Deploying the deployment
* validation before the deployment starts
  * check whether the puppet classes are present in the environments
* 3 main dynflow actions:
  * provision all hosts
    * consists of actions for provisioning a single host
    * will run in parallel
  * run the ordered resources
    * dependent on the previous one
    * consists of actions for each of the ordered resources
    * each ordered resource class returns an apipie action to execute the resource
    * apipie takes care or computing the correct order for them
  * enable puppet
    * dependent on the previous one
    * enable puppet runs for all the hots
