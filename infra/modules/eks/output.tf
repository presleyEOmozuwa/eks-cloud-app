output "cluster_name" {
   value = aws_eks_cluster.main.name
}

output "eks_cluster_ca" {
   value = aws_eks_cluster.main.certificate_authority[0].data
}

output "endpoint" {
   value = aws_eks_cluster.main.endpoint
}

output "frontend_repo_url" {
  value = aws_ecr_repository.react_app.repository_url
}

output "backend_repo_url" {
  value = aws_ecr_repository.node_app.repository_url
}

output "role" {
  value = aws_iam_role.cicd_deploy[var.environment].arn
}



