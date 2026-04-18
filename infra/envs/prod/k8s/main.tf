
provider "kubernetes" {
  host = var.endpoint

  cluster_ca_certificate = base64decode(
    var.eks_cluster_ca
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.cluster_name
    ]
  }
}