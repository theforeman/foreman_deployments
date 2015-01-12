permissions = [
    ['Deploy', 'view_deployments'],
    ['Deploy', 'create_deployments'],
    ['Deploy', 'edit_deployments'],
    ['Deploy', 'destroy_deployments'],
    ['Stack', 'view_stacks'],
    ['Stack', 'create_stacks'],
    ['Stack', 'edit_stacks'],
    ['Stack', 'destroy_stacks']
]
permissions.each do |resource, permission|
  Permission.find_or_create_by_resource_type_and_name resource, permission
end

