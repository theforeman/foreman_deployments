child :depends_on => :depends_on do
  extends "foreman_deployments/api/v2/resources/base"
end

child :depended_by => :depended_by do
  extends "foreman_deployments/api/v2/resources/base"
end
