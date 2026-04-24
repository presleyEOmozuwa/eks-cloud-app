
output "reactapp_repo_arn" {
  value = aws_ecr_repository.react_app.arn
}

output "reactapp_repo_name" {
  value = aws_ecr_repository.react_app.name
}

output "nodeapp_repo_arn" {
  value = aws_ecr_repository.node_app.arn
}

output "nodeapp_repo_name" {
  value = aws_ecr_repository.node_app.name
}

output "frontend_repo_url" {
  value = aws_ecr_repository.react_app.repository_url
}

output "backend_repo_url" {
  value = aws_ecr_repository.node_app.repository_url
}