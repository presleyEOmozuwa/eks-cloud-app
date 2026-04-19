#############################################
# PROVIDERS (assumed defined elsewhere)
#############################################

# aws
# kubernetes
# tls

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
      branch     = "main"
      namespace  = "prod"
      env_level  = "prod"
    }
  }
}

#############################################
# GITHUB OIDC PROVIDER (HARDENED)
#############################################

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]
}

#############################################
# IAM PERMISSION BOUNDARY (ZERO ESCALATION)
#############################################

resource "aws_iam_policy" "permission_boundary" {
  name = "ci-cd-boundary-deny-escalation"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # 🚨 IAM ESCALATION BLOCK
      {
        Effect = "Deny"
        Action = [
          "iam:CreateAccessKey",
          "iam:CreateUser",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:AttachUserPolicy",
          "iam:PutRolePolicy",
          "iam:PutUserPolicy",
          "iam:UpdateAssumeRolePolicy"
        ]
        Resource = "*"
      },
      
      {
         "Effect": "Deny",
         "Action": "iam:PassRole",
         "Resource": "*",
         "Condition": {
           "StringNotLike": {
            "iam:PassedToService": [
              "eks.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
           }
         }
      },
      
      # 🚨 OIDC / IDENTITY PROTECTION
      {
        Effect = "Deny"
        Action = [
          "iam:DeleteOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProvider"
        ]
        Resource = "*"
      },
      
      # 🌍 REGION LOCK
      {
        Effect = "Allow"
        Action = "*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = ["us-east-1", "us-west-2"]
          }
        }
      },
      {
         "Effect": "Deny",
         "Action": "*",
         "Resource": "*",
         "Condition": {
          "StringNotEquals": {
            "aws:RequestedRegion": ["us-east-1", "us-west-2"]
          }
         }
      }
    ]
  })
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
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {

        #########################################
        # AUTHENTICATION CONTROLS
        #########################################
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:repository" = "${var.github_org}/${var.github_repo}"
          "token.actions.githubusercontent.com:ref" = "refs/heads/${each.value.branch}"
          "token.actions.githubusercontent.com:ref_type" = "branch"

          # GitHub Environment protection gate
          "token.actions.githubusercontent.com:environment" = each.key
        }

        #########################################
        # WORKFLOW RESTRICTION (OPTIONAL HARDENING)
        #########################################
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  permissions_boundary = aws_iam_policy.permission_boundary.arn
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
      },

      {
        Effect = "Allow"
        Action = [
          "sts:GetCallerIdentity"
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
          "ecr:GetAuthorizationToken"
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
          aws_ecr_repository.react_app.arn,
          aws_ecr_repository.node_app.arn
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
# EKS ACCESS ENTRY (SINGLE SOURCE OF TRUTH)
#############################################

resource "aws_eks_access_entry" "cicd" {
  for_each = aws_iam_role.cicd_deploy

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value.arn
  type          = "STANDARD"
}

#############################################
# KUBERNETES NAMESPACES (ISOLATION LAYER)
#############################################

resource "kubernetes_namespace_v1" "env" {
  for_each = local.environments

  metadata {
    name = each.value.namespace
  }
}

#############################################
# KUBERNETES RBAC (NO IAM COUPLING)
#############################################

resource "kubernetes_role_v1" "deploy" {
  for_each = local.environments

  metadata {
    name      = "deploy-${each.key}"
    namespace = each.value.namespace
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["services", "configmaps"]
    verbs      = ["get", "list", "watch", "create", "update"]
  }
}

#############################################
# ROLE BINDING (CLEAN K8S USER MODEL)
#############################################

resource "kubernetes_role_binding_v1" "deploy" {
  for_each = local.environments

  metadata {
    name      = "deploy-binding-${each.key}"
    namespace = each.value.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.deploy[each.key].metadata[0].name
  }

  subject {
    kind = "User"

    # EKS Access Entry maps IAM identity → Kubernetes user identity
    
    name = aws_iam_role.cicd_deploy[each.key].arn
  }

  depends_on = [
    kubernetes_namespace_v1.env
  ]
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