
output "vpc" {
  value = try(module.vpc[0], null)
}

output "rds" {
  value = try(module.rds_authentik[0], null)
}

output "rds_security_group" {
  value = try(module.sg_rds[0], null)
}

output "alb" {
  value = try(module.alb_authentik[0], null)
}

output "ecs" {
  value = try(module.ecs_authentik[0], null)
}
