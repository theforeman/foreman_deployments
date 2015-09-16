class AddTaxonomyToDeployments < ActiveRecord::Migration
  def change
    add_column :deployments, :organization_id, :integer
    add_column :deployments, :location_id, :integer
    add_foreign_key :deployments, :taxonomies, :name => :deployemnts_organziation_id_fk, :column => :organization_id
    add_foreign_key :deployments, :taxonomies, :name => :deployemnts_location_id_fk, :column => :location_id
  end
end
