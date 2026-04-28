
terraform {
  backend "s3" {
    bucket = "presley-terraform-state-2026"
    key    = "dev/aws.tfstate"
    region = "us-east-1"
  }
}
