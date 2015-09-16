module ForemanDeployments
  class Deployment < ActiveRecord::Base
    include Authorizable

    belongs_to :configuration, :class_name => 'ForemanDeployments::Configuration', :autosave => true

    validates :name, :presence => true
    validates :configuration,   :presence => true
    validates :organization_id, :presence => true, :if => lambda { SETTINGS[:organizations_enabled] }
    validates :organization_id,
              :inclusion => {
                :in => lambda { |d| d.stack.organizations.map(&:id) },
                :message => _("Deployment's organization must be one of the stack's organizations.")
              },
              :if => lambda { |d| SETTINGS[:organizations_enabled] && !d.stack.nil? }
    validates :location_id, :presence => true, :if => lambda { SETTINGS[:locations_enabled] }
    validates :location_id,
              :inclusion => {
                :in => lambda { |d| d.stack.locations.map(&:id) },
                :message => _("Deployment's location must be one of the stack's locations.")
              },
              :if => lambda { |d| SETTINGS[:organizations_enabled] && !d.stack.nil? }

    belongs_to :location
    belongs_to :organization

    scoped_search :on => :id, :complete_value => false
    scoped_search :on => :name, :complete_value => true, :default_order => true
    if SETTINGS[:locations_enabled]
      scoped_search :in => :location, :on => :title, :rename => :location, :complete_value => true
      scoped_search :on => :location_id, :complete_enabled => false, :only_explicit => true
    end
    if SETTINGS[:organizations_enabled]
      scoped_search :in => :organization, :on => :title, :rename => :organization, :complete_value => true
      scoped_search :on => :organization_id, :complete_enabled => false, :only_explicit => true
    end

    scope :no_location,     lambda { where(:location_id => nil) }
    scope :no_organization, lambda { where(:organization_id => nil) }

    default_scope do
      where(taxonomy_conditions)
    end

    def self.taxonomy_conditions
      org = Organization.expand(Organization.current) if SETTINGS[:organizations_enabled]
      loc = Location.expand(Location.current) if SETTINGS[:locations_enabled]
      conditions = {}
      conditions[:organization_id] = Array(org).map(&:subtree_ids).flatten.uniq if org.present?
      conditions[:location_id] = Array(loc).map(&:subtree_ids).flatten.uniq if loc.present?
      conditions
    end

    def stack
      configuration.stack if configuration
    end

    def parsed_stack
      @parsed_stack ||= ForemanDeployments::StackParser.parse(stack.definition) unless stack.nil?
    end
  end
end
