locals {
  base_cidr = "10.0.0.0/16"
  az = "us-east-1"
  public_subnet = {
    name     = "public"
    new_bits = 8
  }
  private_subnet = {
    name     = "private"
    new_bits = 8
  }
  enable_nat_gateway           = true
  single_nat_gateway           = true
  one_nat_gateway_per_az       = false
  cicd_permissions_policy_path = "${path.module}/policies/cicd-policy.json.tpl"
  cicd_trust_policy_path       = "${path.module}/policies/cicd-trust-policy.json.tpl"
  cicd_role = {
    role_name   = "cicd${local.roleend}"
    policy_name = "cicd${local.policyend}"
    policy_path = "/cicd/"
  }

}
data "aws_caller_identity" "current" {}

module "codebuild_subnet_addrs" {
  source          = "hashicorp/subnets/cidr"
  version         = "1.0.0"
  base_cidr_block = local.base_cidr
  networks = [
    local.public_subnet,
    local.private_subnet
  ]
}

module "codebuild_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = var.codebuild_vpc_name
  cidr = module.codebuild_subnet_addrs.base_cidr_block

  azs             = [local.az]
  private_subnets = [module.codebuild_subnet_addrs.network_cidr_blocks[local.private_subnet.name]]
  public_subnets  = [module.codebuild_subnet_addrs.network_cidr_blocks[local.public_subnet.name]]

  enable_nat_gateway     = local.enable_nat_gateway
  single_nat_gateway     = local.single_nat_gateway
  one_nat_gateway_per_az = local.one_nat_gateway_per_az

  depends_on = [
    module.codebuild_subnet_addrs
  ]
}

module "iam_github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "5.52.2"
}

resource "aws_iam_policy" "cicd_policy" {
  name = local.cicd_role.policy_name
  path = local.cicd_role.policy_path

  policy = templatefile(local.cicd_permissions_policy_path, {
    vpc        = module.codebuild_vpc.vpc_arn,
    account_id = data.aws_caller_identity.current.account_id
  })
}

resource "aws_iam_role" "cicd_role" {
  name = local.cicd_role.role_name

  assume_role_policy = templatefile(local.cicd_trust_policy_path, {
    account_id = data.aws_caller_identity.current.account_id
  })
}

resource "aws_iam_role_policy_attachment" "cicd_role_policy_attachment" {
  policy_arn = aws_iam_policy.cicd_policy.arn
  role       = aws_iam_role.cicd_role.name

  depends_on = [
    aws_iam_policy.cicd_policy,
    aws_iam_role.cicd_role
  ]
}

