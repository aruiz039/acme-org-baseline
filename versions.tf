terraform {
  required_version = ">= 1.14, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }
  backend "s3" {
    bucket       = "acme-tfstate-mgmt-406430962795"
    key          = "org-baseline/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
    # NOTE: no profile here. CI uses OIDC. For local plans you'd pass --profile via CLI.
  }
}

provider "aws" {
  region = "us-east-1"
}