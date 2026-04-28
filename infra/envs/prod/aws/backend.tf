
terraform {
  backend "s3" {
    bucket = "presley-terraform-state-prod-2026"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
