
output "vpc" {
  value = try(module.vpc[0], null)
  description = "vpc module output from https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest?tab=outputs"
}

output "rds" {
  value = try(module.rds_authentik[0], null)
  description = "rds module output from https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest?tab=outputs"
}

output "rds_security_group" {
  value = try(module.sg_rds[0], null)
  description = "rds security group module output from https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest?tab=outputs"
}

output "alb" {
  value = try(module.alb_authentik[0], null)
  description = "alb module output from https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest?tab=outputs"
}

output "ecs" {
  value = try(module.ecs_authentik[0], null)
  description = "ecs module output from https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest?tab=outputs"
}
