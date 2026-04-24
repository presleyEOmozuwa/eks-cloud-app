#############################################
# LOCALS
#############################################

locals {
  name_prefix = "${var.project}-${var.environment}"
}

#############################################
# ECR REPOSITORIES
#############################################

resource "aws_ecr_repository" "react_app" {
  name                 = "${local.name_prefix}-react"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "node_app" {
  name                 = "${local.name_prefix}-node"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}