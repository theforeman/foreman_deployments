module ForemanDeployments
  module EnsureAssociationPresent
    def ensure_association_present(assoc)
      after_save do
        if send(self.class.reflect_on_association(assoc).foreign_key).nil?
          raise "association #{assoc} missing"
        end
      end
    end
  end
end
