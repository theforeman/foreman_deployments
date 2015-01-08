module ForemanDeployments
  module EnsureAssociationPresent
    def ensure_association_present(assoc)
      after_save do
        raise "association #{assoc} missing" unless Host.reflect_on_association(assoc).foreign_key
      end
    end
  end
end
