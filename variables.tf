variable "create" {
  type        = bool
  default     = true
  description = "create/deploy authentik"
}

################################################################################
# VPC
################################################################################

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "vpc cidr of created vpc within this module"
}

variable "vpc_tags" {
  type        = map(string)
  default     = {}
  description = "Tags for vpc  module"
}

################################################################################
# RDS
################################################################################

variable "rds_instance_type" {
  type        = string
  default     = "m5.large"
  description = "RDS PostfreSQL instacne type  (without the leading db.)"
}

variable "rds_version" {
  type        = string
  default     = "17.5"
  description = "RDS PostgreSQL version"
}

variable "rds_storage_size" {
  type        = number
  default     = 5
  description = "RDS PostgreSQL storage size in GB"
}

variable "rds_security_group_tags" {
  type    = map(string)
  default = {}
}

variable "rds_tags" {
  type    = map(string)
  default = {}
}


################################################################################
# ALB
################################################################################

variable "certificate_arn" {
  type    = string
  default = null
}

variable "alb_tags" {
  type    = map(string)
  default = {}
}

################################################################################
# ECS / AUTHENTIK
################################################################################

variable "authentik_image" {
  type    = string
  default = "ghcr.io/goauthentik/server"
}

variable "authentik_version" {
  type        = string
  default     = "2026.8.3"
  description = "authentik Docker image tag"
}

variable "authentik_server_cpu" {
  type        = number
  default     = 512
  description = "authentik server CPU units (1024 = 1 vCPU)"
}

variable "authentik_server_memory" {
  type        = number
  default     = 1024
  description = "authentik server memory in MiB"
}

variable "authentik_server_replica" {
  type        = number
  default     = 1
  description = "Desired number of authentik server tasks"
}

variable "authentik_worker_cpu" {
  type        = number
  default     = 512
  description = "authentik worker CPU units (1024 = 1 vCPU)"
}

variable "authentik_worker_memory" {
  type        = number
  default     = 1024
  description = "authentik worker memory in MiB"
}

variable "authentik_worker_replica" {
  type        = number
  default     = 1
  description = "Desired number of authentik worker tasks"
}

variable "authentik_log_retention_in_days" {
  type        = number
  default     = 7
  description = "CloudWatch Log Group retention in days"
}

variable "ecs_tags" {
  type    = map(string)
  default = {}
}

################################################################################
# GENERAL
################################################################################

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources"
}
