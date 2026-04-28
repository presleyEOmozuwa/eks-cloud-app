module "k8s" {
  source = "../../../modules/k8s"
  deploy_role_arn = data.terraform_remote_state.aws.outputs.deploy_role_arn
}