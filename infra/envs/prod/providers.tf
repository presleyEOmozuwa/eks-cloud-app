terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "presley-terraform-state-prod-2026"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host = module.eks.endpoint

  cluster_ca_certificate = base64decode(
    module.eks.cluster_ca
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}