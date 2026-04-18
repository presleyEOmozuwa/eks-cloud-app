terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "presley-terraform-state-staging-2026"
    key    = "staging/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}