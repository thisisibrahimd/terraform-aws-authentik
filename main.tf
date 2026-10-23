data "aws_availability_zones" "available" {}

locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  vpc_cidr = var.vpc_cidr
}

################################################################################
# VPC
################################################################################

module "vpc_authentik" {
  count = var.create ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-authentik"
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true
  enable_nat_gateway = true
  single_nat_gateway = true
  create_igw = true
  enable_dns_support = true
  enable_dns_hostnames = true
  map_public_ip_on_launch = true

  tags = merge(var.tags, var.vpc_tags)
}


################################################################################
# RDS
################################################################################

module "rds_authentik" {
  count = var.create ? 1 : 0

  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.0"

  identifier = "rds-authentik"

  engine            = "postgres"
  engine_version    = var.rds_version
  instance_class    = "db.${var.rds_instance_type}"
  allocated_storage = var.rds_storage_size

  storage_type = "gp2"

  db_name  = "authentik"
  username = "authentik"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.sg_rds[0].id]

  create_db_subnet_group = false
  db_subnet_group_name = module.vpc_authentik[0].database_subnet_group
  subnet_ids = module.vpc_authentik[0].database_subnets

  multi_az               = false

  publicly_accessible = false

  copy_tags_to_snapshot = true

  deletion_protection = false
  create_monitoring_role = false
  create_db_option_group = false
  create_db_parameter_group = false

  tags = merge(var.tags, var.rds_tags)
}

module "sg_rds" {
  count = var.create ? 1 : 0

  source = "terraform-aws-modules/security-group/aws"

  name        = "rds"
  description = "Security Group for RDS"
  vpc_id      = module.vpc_authentik[0].vpc_id

  ingress_rules = {
    allow-authentik-server = {
      from_port = 5432
      ip_protocol = "tcp"
      description = "Allow authentik server to connect to RDS"
      referenced_security_group_id = module.ecs_authentik[0].services["server"].security_group_id
    }
    allow-authentik-worker = {
      from_port = 5432
      ip_protocol = "tcp"
      description = "Allow authentik worker to connect to RDS"
      referenced_security_group_id = module.ecs_authentik[0].services["worker"].security_group_id
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic by default"
    }
  }

  tags = merge(var.tags, var.rds_security_group_tags)
}

################################################################################
# ALB
################################################################################

module "alb_authentik" {
  count = var.create ? 1 : 0

  source = "terraform-aws-modules/alb/aws"

  name    = "alb-authentik"
  vpc_id  = module.vpc_authentik[0].vpc_id
  subnets = module.vpc_authentik[0].public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    allow-authentik = {
      ip_protocol = "tcp"
      from_port = 9000
      to_port = 9000
      description = "Load balancer to target group"
      referenced_security_group_id = module.ecs_authentik[0].services["server"].security_group_id
    }
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"

      forward = {
        target_group_key = "tg-authentik"
      }
    }
  }

  target_groups = {
    tg-authentik = {
      name_prefix      = "ak-"
      protocol         = "HTTP"
      port             = 9000
      target_type      = "ip"
      create_attachment = false
      vpc_id = module.vpc_authentik[0].vpc_id
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/-/health/live/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  }

  enable_deletion_protection = false

  tags = merge(var.tags, var.lb_tags)
}

module "secret_authentik_secret_key" {
  count = var.create ? 1 : 0

  source = "terraform-aws-modules/secrets-manager/aws"

  name_prefix             = "authentik_secret_key"
  description             = "Authentik Secret Key"
  recovery_window_in_days = 7

  create_random_password           = true
  random_password_length           = 64
  random_password_override_special = "!@#$%^&*()_+"

  tags = var.tags
}

################################################################################
# ECS / AUTHENTIK
################################################################################

module "ecs_authentik" {
  count = var.create ? 1 : 0

  source = "terraform-aws-modules/ecs/aws"
  version = "~> 7.0"

  cluster_name = "ecs-authentik"

  cluster_capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 100
    }
  }

  create_cloudwatch_log_group = true
  vpc_id = module.vpc_authentik[0].vpc_id

  services = {
    server = {
      enable_ecs_managed_tags = true
      create_tasks_iam_role = true
      create_task_exec_iam_role = true
      task_exec_secret_arns = [
        module.secret_authentik_secret_key[0].secret_arn,
        module.rds_authentik[0].db_instance_master_user_secret_arn,
      ]
      enable_execute_command = true
      container_definitions = {
        server = {
          command = ["server"]
          restartPolicy = {
            enabled = true
          }
          cpu       = var.authentik_server_cpu
          environment = [
            {
              name = "AUTHENTIK_POSTGRESQL__HOST",
              value = module.rds_authentik[0].db_instance_address
            },
            {
              name = "AUTHENTIK_POSTGRESQL__USER",
              value = "authentik"
            },
            {
              name = "AUTHENTIK_POSTGRESQL__SSLMODE",
              value = "require"
            }
          ]
          essential = true
          healthCheck = {
            command = [
              "CMD",
              "ak",
              "healthcheck"
            ]
          }
          image = "${var.authentik_image}:${var.authentik_version}"
          enable_cloudwatch_logging = true
          create_cloudwatch_log_group = true
          cloudwatch_log_group_use_name_prefix = "/authentik/server"
          cloudwatch_log_group_retention_in_days = 1
          memory    = var.authentik_server_memory
          secrets = [
            {
              name      = "AUTHENTIK_POSTGRESQL__PASSWORD"
              valueFrom = "${module.rds_authentik[0].db_instance_master_user_secret_arn}:password::"
            },
            {
              name      = "AUTHENTIK_SECRET_KEY"
              valueFrom = module.secret_authentik_secret_key[0].secret_arn
            }
          ]
          portMappings = [
            {
              containerPort = 9000
              protocol      = "tcp"
            }
          ]
        }
      }

      desired_count = var.authentik_server_replica

      load_balancer = {
        service = {
          target_group_arn = module.alb_authentik[0].target_groups["tg-authentik"].arn
          container_name   = "server"
          container_port   = 9000
        }
      }

      subnet_ids = module.vpc_authentik[0].private_subnets

      security_group_ingress_rules = {
        allow-alb = {
          description                  = "Service port"
          from_port                    = 9000
          ip_protocol                  = "tcp"
          referenced_security_group_id = module.alb_authentik[0].security_group_id
        }
      }
      security_group_egress_rules = {
        all = {
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }
    }
    worker = {
      enable_ecs_managed_tags = true
      create_tasks_iam_role = true
      create_task_exec_iam_role = true
      task_exec_secret_arns = [
        module.secret_authentik_secret_key[0].secret_arn,
        module.rds_authentik[0].db_instance_master_user_secret_arn,
      ]
      enable_execute_command = true
      container_definitions = {
        worker = {
          command = ["worker"]
          cpu       = var.authentik_worker_cpu
          restartPolicy = {
            enabled = true
          }
          environment = [
            {
              name = "AUTHENTIK_POSTGRESQL__USER",
              value = "authentik"
            },
            {
              name = "AUTHENTIK_POSTGRESQL__HOST",
              value = module.rds_authentik[0].db_instance_address
            },
            {
              name = "AUTHENTIK_POSTGRESQL__SSLMODE",
              value = "require"
            }
          ]
          essential = true
          healthCheck = {
            command = [
              "CMD",
              "ak",
              "healthcheck"
            ]
          }
          image = "${var.authentik_image}:${var.authentik_version}"
          enable_cloudwatch_logging = true
          create_cloudwatch_log_group = true
          cloudwatch_log_group_use_name_prefix = "/authentik/worker"
          cloudwatch_log_group_retention_in_days = 1
          memory    = var.authentik_worker_memory
          secrets = [
            {
              name      = "AUTHENTIK_POSTGRESQL__PASSWORD"
              valueFrom = "${module.rds_authentik[0].db_instance_master_user_secret_arn}:password::"
            },
            {
              name      = "AUTHENTIK_SECRET_KEY"
              valueFrom = module.secret_authentik_secret_key[0].secret_arn
            }
          ]
        }
      }

      subnet_ids = module.vpc_authentik[0].private_subnets

      desired_count = var.authentik_worker_replica
      
      security_group_ingress_rules = {
        allow-alb = {
          description                  = "Service port"
          from_port                    = 9000
          ip_protocol                  = "tcp"
          referenced_security_group_id = module.alb_authentik[0].security_group_id
        }
      }
      security_group_egress_rules = {
        all = {
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }
    }
  }

  tags = merge(var.tags, var.ecs_tags)
}


