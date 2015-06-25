# rubocop:disable Style/FileName
permissions = [
  %w(Deploy view_deployments),
  %w(Deploy create_deployments),
  %w(Deploy edit_deployments),
  %w(Deploy destroy_deployments),
  %w(Stack view_stacks),
  %w(Stack create_stacks),
  %w(Stack edit_stacks),
  %w(Stack destroy_stacks)
]
permissions.each do |resource, permission|
  Permission.find_or_create_by_resource_type_and_name resource, permission
end
