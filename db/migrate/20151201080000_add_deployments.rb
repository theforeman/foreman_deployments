class AddDeployments < ActiveRecord::Migration

  def change
    create_table 'foreman_deployments_deployments' do |t|
      t.string 'name', :null => false
      t.references :organization
      t.references :location
      t.timestamps
    end

    create_table 'foreman_deployments_stacks' do |t|
      t.string 'name', :null => false
      t.references :organization
      t.references :location
      t.timestamps
    end

    create_table 'foreman_deployments_resources' do |t|
      t.string 'type'
      t.string 'name'
      t.string 'value'
      t.integer 'min'
      t.integer 'max'
      t.timestamps

      t.references :hostgroup
      t.references :host
      t.references :puppetclass
      t.references :parameter
    end

    create_table 'foreman_deployments_resource_dependencies' do |t|
      t.references :depends_on
      t.references :depended_by
    end

    # TODO foreign keys

  end

end
