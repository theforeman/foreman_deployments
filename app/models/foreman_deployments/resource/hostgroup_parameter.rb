module ForemanDeployments
  module Resource
    class HostgroupParameter < Parameter
      belongs_to :hostgroup, class_name: 'ForemanDeployments::Resource::Hostgroup'
      ensure_association_present :hostgroup
    end
  end
end
