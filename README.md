# AWS Authentik Terraform module

Terraform module which deploys [Authentik](https://goauthentik.io/) on AWS.

## Usage

```hcl
module "authentik" {
  source = "thisisibrahimd/terraform-aws-authentik"

}

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_alb_authentik"></a> [alb\_authentik](#module\_alb\_authentik) | terraform-aws-modules/alb/aws | n/a |
| <a name="module_ecs_authentik"></a> [ecs\_authentik](#module\_ecs\_authentik) | terraform-aws-modules/ecs/aws | ~> 7.0 |
| <a name="module_rds_authentik"></a> [rds\_authentik](#module\_rds\_authentik) | terraform-aws-modules/rds/aws | ~> 7.0 |
| <a name="module_secret_authentik_secret_key"></a> [secret\_authentik\_secret\_key](#module\_secret\_authentik\_secret\_key) | terraform-aws-modules/secrets-manager/aws | n/a |
| <a name="module_sg_rds"></a> [sg\_rds](#module\_sg\_rds) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_vpc_authentik"></a> [vpc\_authentik](#module\_vpc\_authentik) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_authentik_image"></a> [authentik\_image](#input\_authentik\_image) | n/a | `string` | `"ghcr.io/goauthentik/server"` | no |
| <a name="input_authentik_log_retention_in_days"></a> [authentik\_log\_retention\_in\_days](#input\_authentik\_log\_retention\_in\_days) | CloudWatch Log Group retention in days | `number` | `7` | no |
| <a name="input_authentik_server_cpu"></a> [authentik\_server\_cpu](#input\_authentik\_server\_cpu) | authentik server CPU units (1024 = 1 vCPU) | `number` | `512` | no |
| <a name="input_authentik_server_memory"></a> [authentik\_server\_memory](#input\_authentik\_server\_memory) | authentik server memory in MiB | `number` | `1024` | no |
| <a name="input_authentik_server_replica"></a> [authentik\_server\_replica](#input\_authentik\_server\_replica) | Desired number of authentik server tasks | `number` | `1` | no |
| <a name="input_authentik_version"></a> [authentik\_version](#input\_authentik\_version) | authentik Docker image tag | `string` | `"2026.8.3"` | no |
| <a name="input_authentik_worker_cpu"></a> [authentik\_worker\_cpu](#input\_authentik\_worker\_cpu) | authentik worker CPU units (1024 = 1 vCPU) | `number` | `512` | no |
| <a name="input_authentik_worker_memory"></a> [authentik\_worker\_memory](#input\_authentik\_worker\_memory) | authentik worker memory in MiB | `number` | `1024` | no |
| <a name="input_authentik_worker_replica"></a> [authentik\_worker\_replica](#input\_authentik\_worker\_replica) | Desired number of authentik worker tasks | `number` | `1` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | create/deploy authentik | `bool` | `true` | no |
| <a name="input_create_hosted_zone_records"></a> [create\_hosted\_zone\_records](#input\_create\_hosted\_zone\_records) | n/a | `bool` | `false` | no |
| <a name="input_ecs_tags"></a> [ecs\_tags](#input\_ecs\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_lb_tags"></a> [lb\_tags](#input\_lb\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_rds_instance_type"></a> [rds\_instance\_type](#input\_rds\_instance\_type) | RDS PostfreSQL instacne type  (without the leading db.) | `string` | `"m5.large"` | no |
| <a name="input_rds_security_group_tags"></a> [rds\_security\_group\_tags](#input\_rds\_security\_group\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_rds_storage_size"></a> [rds\_storage\_size](#input\_rds\_storage\_size) | RDS PostgreSQL storage size in GB | `number` | `5` | no |
| <a name="input_rds_tags"></a> [rds\_tags](#input\_rds\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_rds_version"></a> [rds\_version](#input\_rds\_version) | RDS PostgreSQL version | `string` | `"17.5"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | vpc cidr of created vpc within this module | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Tags for vpc  module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb"></a> [alb](#output\_alb) | n/a |
| <a name="output_ecs"></a> [ecs](#output\_ecs) | n/a |
| <a name="output_rds"></a> [rds](#output\_rds) | n/a |
| <a name="output_rds_security_group"></a> [rds\_security\_group](#output\_rds\_security\_group) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
```
