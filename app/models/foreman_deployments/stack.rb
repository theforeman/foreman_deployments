module ForemanDeployments
  class Stack < ActiveRecord::Base
    validates :name, :presence => true, :uniqueness => true
    validates :definition, :presence => true

    # TODO: add taxonimization
  end
end
