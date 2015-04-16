class AddDeployments < ActiveRecord::Migration

  def change
    create_table 'FD_deployments' do |t|
      t.string 'name', :null => false
      t.text 'description'
      t.references :organization
      t.references :location
      t.timestamps
    end

    create_table 'FD_stacks' do |t|
      t.string 'name', :null => false
      t.text 'description'
      t.references :organization
      t.references :location
      t.timestamps
    end

    create_table 'FD_resources' do |t|
      t.string 'type'
      t.text 'description'
      t.string 'name'
      t.string 'value'
      t.integer 'min'
      t.integer 'max'

      t.references :stack
      t.references :hostgroup
      t.references :host
      t.references :puppet_class
      t.references :parameter
    end

    create_table 'FD_resource_dependencies' do |t|
      t.references :depends_on
      t.references :depended_by
    end

    create_table 'FD_stack_deployments' do |t|
      t.references :deployment
      t.references :stack
    end

    create_table 'FD_hostgroup_deployments' do |t|
      t.references :deployment
      t.references :resource
      t.references :hostgroup
    end

    create_table 'FD_assoc_hostgroups' do |t|
      t.references :deployment
      t.references :resource
      t.references :hostgroup
    end

    create_table 'FD_assoc_hostgroup_parameters' do |t|
      t.references :deployment
      t.references :resource
      t.references :group_parameter
    end

    # TODO foreign keys

  end

end
