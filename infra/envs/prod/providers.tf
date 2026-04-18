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