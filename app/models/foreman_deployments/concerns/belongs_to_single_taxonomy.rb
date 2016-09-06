module ForemanDeployments
  module Concerns
    module BelongsToSingleTaxonomy
      extend ActiveSupport::Concern

      included do
        validates :organization_id, :presence => true, :if => -> { SETTINGS[:organizations_enabled] }
        validates :location_id, :presence => true, :if => -> { SETTINGS[:locations_enabled] }

        belongs_to :location
        belongs_to :organization

        if SETTINGS[:locations_enabled]
          scoped_search :in => :location, :on => :title, :rename => :location, :complete_value => true
          scoped_search :on => :location_id, :complete_enabled => false, :only_explicit => true
        end
        if SETTINGS[:organizations_enabled]
          scoped_search :in => :organization, :on => :title, :rename => :organization, :complete_value => true
          scoped_search :on => :organization_id, :complete_enabled => false, :only_explicit => true
        end

        scope :no_location,     -> { where(:location_id => nil) }
        scope :no_organization, -> { where(:organization_id => nil) }

        default_scope do
          where(taxonomy_conditions)
        end
      end

      module ClassMethods
        def taxonomy_conditions
          org = Organization.expand(Organization.current) if SETTINGS[:organizations_enabled]
          loc = Location.expand(Location.current) if SETTINGS[:locations_enabled]
          conditions = {}
          conditions[:organization_id] = Array(org).map(&:subtree_ids).flatten.uniq if org.present?
          conditions[:location_id] = Array(loc).map(&:subtree_ids).flatten.uniq if loc.present?
          conditions
        end
      end
    end
  end
end
