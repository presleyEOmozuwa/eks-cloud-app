data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    bucket = "presley-terraform-state-2026"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "kubernetes" {
  host = data.terraform_remote_state.aws.outputs.cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.aws.outputs.cluster_ca
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.terraform_remote_state.aws.outputs.cluster_name
    ]
  }
}