
terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }

  provider_meta "aws" {
    user_agent = [
      "github.com/thisisibrahimd/terraform-aws-authentik"
    ]
  }
}
