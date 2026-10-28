provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "authentik-${basename(path.cwd)}"
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"

  tags = {
    Project = local.name
  }
}

################################################################################
# Authentik Module
################################################################################

module "authentik" {
  source = "../../"

  vpc_cidr = local.vpc_cidr

  tags = local.tags
}


