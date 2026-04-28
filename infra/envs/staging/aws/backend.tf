
terraform {
  backend "s3" {
    bucket = "presley-terraform-state-staging-2026"
    key    = "staging/terraform.tfstate"
    region = "us-east-1"
  }
}
