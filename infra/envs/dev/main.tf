
module "vpc" {
  source = "../../modules/vpc"
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
  source = "../../modules/eks"
  subnet_ids = module.vpc.subnet_ids
  cluster_name = "ekscluster-${var.environment}"
  project = var.project
  region = var.region
  github_org = var.github_org
  github_repo = var.github_repo
  environment = var.environment
}
