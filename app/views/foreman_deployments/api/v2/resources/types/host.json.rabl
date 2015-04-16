attribute :name, :min, :max

child :hostgroup  do
  extends "foreman_deployments/api/v2/resources/base"
end

