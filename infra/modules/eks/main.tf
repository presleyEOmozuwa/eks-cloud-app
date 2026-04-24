
#############################################
# LOCALS
#############################################

locals {
  name_prefix = "${var.project}-${var.environment}"
}

#############################################
# EKS CLUSTER
#############################################

resource "aws_eks_cluster" "main" {
  name     = "${local.name_prefix}-cluster"
  role_arn = var.eks_role_arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator"
  ]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

#############################################
# NODE GROUP
#############################################

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  instance_types = ["t3.medium"]
  ami_type       = "AL2_x86_64"

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

#############################################
# EKS ACCESS ENTRY (SINGLE SOURCE OF TRUTH)
#############################################

resource "aws_eks_access_entry" "cicd" {
  for_each = var.cicd_role_arns

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
  type          = "STANDARD"
}