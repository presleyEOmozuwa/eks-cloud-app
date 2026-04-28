module "iam" {
  source = "../../../modules/iam"
  reactapp_repo_arn = module.ecr.reactapp_repo_arn
  nodeapp_repo_arn = module.ecr.nodeapp_repo_arn
  github_org = var.github_org
  github_repo = var.github_repo
  project = var.project
  environment = var.environment
  
}

module "vpc" {
  source = "../../../modules/vpc"
  region = var.region
  vpc_tags = {
     Name        = "${var.project}-${var.environment}-vpc"
     Environment = var.environment
     Project     = var.project
  }
  igw_tags = var.igw_tags
  rt_tags = var.rt_tags
  sg_tags = var.sg_tags
  public_subnet_tags_1 = var.public_subnet_tags_1
  public_subnet_tags_2 = var.public_subnet_tags_2

}

module "eks" {
  source = "../../../modules/eks"
  subnet_ids = module.vpc.subnet_ids
  cicd_role_arns = module.iam.cicd_role_arns
  eks_role_arn = module.iam.eks_role_arn
  node_role_arn = module.iam.node_role_arn
  project = var.project
  environment = var.environment
}

module "ecr" {
  source = "../../../modules/ecr"
  project = var.project
  environment = var.environment
}

