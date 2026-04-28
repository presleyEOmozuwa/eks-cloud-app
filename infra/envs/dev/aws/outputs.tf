output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.endpoint
}

output "cluster_ca" {
  value = module.eks.cluster_ca
}

output "deploy_role_arn" {
  value = module.iam.deploy_role_arn
}