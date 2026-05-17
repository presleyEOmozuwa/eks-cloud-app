#############################################
# LOCALS
#############################################

locals {
  name_prefix = "${var.project}-${var.environment}"
}

#############################################
# LOCALS (ENVIRONMENT MODEL)
#############################################

locals {
  environments = {
    dev = {
      branch     = "dev"
      namespace  = "dev"
      env_level  = "dev"
    }
    staging = {
      branch     = "staging"
      namespace  = "staging"
      env_level  = "staging"
    }
    prod = {
      branch     = "prod"
      namespace  = "prod"
      env_level  = "prod"
    }
  }
}

#############################################
# IAM ROLES
#############################################

# EKS Cluster Role
resource "aws_iam_role" "eks_role" {
  name = "${local.name_prefix}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Node Group Role
resource "aws_iam_role" "node_role" {
  name = "${local.name_prefix}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

#############################################
# IAM POLICY ATTACHMENTS
#############################################

# Node policies
resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cni" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Cluster policies
resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

#############################################
# GITHUB OIDC PROVIDER (HARDENED)
#############################################

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}


#############################################
# CI/CD ROLE (DEPLOY - ENVIRONMENT GATED)
#############################################

resource "aws_iam_role" "cicd_deploy" {
  for_each = local.environments

  name = "cicd-deploy-${each.key}"

  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        #########################################
        # AUTHENTICATION CONTROLS
        #########################################
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })
  
}

#############################################
# EKS MINIMAL ACCESS POLICY
#############################################

resource "aws_iam_policy" "cicd_eks" {
  name = "cicd-eks-minimal"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

#############################################
# ECR MINIMAL ACCESS POLICY
#############################################

resource "aws_iam_policy" "cicd_ecr" {
  name = "cicd-ecr-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # Required for docker login
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      },

      # Push / Pull access (scope to your repos if possible)
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories"

        ]
        Resource = [
          var.reactapp_repo_arn,
          var.nodeapp_repo_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_eks" {
  for_each = aws_iam_role.cicd_deploy

  role       = each.value.name
  policy_arn = aws_iam_policy.cicd_eks.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecr" {
  for_each = aws_iam_role.cicd_deploy

  role       = each.value.name
  policy_arn = aws_iam_policy.cicd_ecr.arn
}


#############################################
# OPTIONAL: INFRA ROLE (SEPARATION OF DUTY)
#############################################

resource "aws_iam_role" "cicd_infra" {
  for_each = local.environments

  name = "cicd-infra-${each.key}"

  assume_role_policy = aws_iam_role.cicd_deploy[each.key].assume_role_policy

  permissions_boundary = aws_iam_policy.permission_boundary.arn
}