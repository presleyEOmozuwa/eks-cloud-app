
output "eks_role_arn" {
   value = aws_iam_role.eks_role.arn
}

output "eksrole_name" {
   value = aws_iam_role.eks_role.name
}

output "node_role_arn" {
   value = aws_iam_role.node_role.arn
}

output "noderole_name" {
   value = aws_iam_role.node_role.name
}

output "cicd_role_arns" {
  value = {
    for k, v in aws_iam_role.cicd_deploy :
    k => v.arn
  }
}

output "deploy_role_arn" {
  value = aws_iam_role.cicd_deploy[var.environment].arn
}

output "deploy_policy_attachment_arn" {
  value = aws_iam_role.cicd_deploy[var.environment].arn
}

output "ecr_policy_attachment" {
  value = aws_iam_role_policy_attachment.ecr
}

output "cni_policy_attachment" {
  value = aws_iam_role_policy_attachment.cni
}

output "cluster_policy_attachment" {
  value = aws_iam_role_policy_attachment.cluster
}

output "vpc_policy_attachment" {
  value = aws_iam_role_policy_attachment.vpc
}


output "node_policy_attachment" {
  value = aws_iam_role_policy_attachment.node_worker
}