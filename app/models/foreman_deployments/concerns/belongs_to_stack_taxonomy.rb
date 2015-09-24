module ForemanDeployments
  module Concerns
    module BelongsToStackTaxonomy
      extend ActiveSupport::Concern

      included do
        include BelongsToSingleTaxonomy

        validates :organization_id,
                  :inclusion => {
                    :in => lambda { |d| d.stack.organizations.map(&:id) },
                    :message => _("Deployment's organization must be one of the stack's organizations.")
                  },
                  :if => lambda { |d| SETTINGS[:organizations_enabled] && !d.stack.nil? }
        validates :location_id,
                  :inclusion => {
                    :in => lambda { |d| d.stack.locations.map(&:id) },
                    :message => _("Deployment's location must be one of the stack's locations.")
                  },
                  :if => lambda { |d| SETTINGS[:organizations_enabled] && !d.stack.nil? }
      end
    end
  end
end
