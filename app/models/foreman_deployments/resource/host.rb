module ForemanDeployments
  module Resource
    class Host < Abstract
      belongs_to :hostgroup, class_name: 'ForemanDeployments::Resource::Hostgroup'
      ensure_association_present :hostgroup

      has_many :puppet_runs, class_name: 'ForemanDeployments::Resource::PuppetRun'

      # name (e.g. 'db-%02d}' to generate the names, possibly %g for group etc)
      validates :name, :min, :max, presence: true

      validates_each :max do |r, a, v|
        r.errors.add a, 'min has to be smaller or equal than max' if r.min > v
      end
    end
  end
end
