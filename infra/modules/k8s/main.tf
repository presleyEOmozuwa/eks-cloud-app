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
    
    name = var.deploy_role_arn
  }

  depends_on = [
    kubernetes_namespace_v1.env
  ]
}

