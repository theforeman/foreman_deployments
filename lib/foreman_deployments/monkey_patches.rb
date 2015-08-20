module ActiveRecord
  class Base
    # adding to_hash to enable for using in dynflog actions' output
    def to_hash
      # TODO: replace passwords
      attributes
    end
  end
end
