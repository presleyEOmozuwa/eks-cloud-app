terraform {
  backend "s3" {
    bucket = "presley-terraform-state-2026"
    key    = "dev/k8s.tfstate"
    region = "us-east-1"
  }
}

