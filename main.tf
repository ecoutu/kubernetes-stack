# Main Terraform configuration file

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name     = var.environment
  vpc_cidr = var.vpc_cidr
  az_count = var.az_count

  enable_nat_gateway      = var.enable_nat_gateway
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  account_alias   = "ecoutu"
  user_name       = "ecoutu"
  admin_role_name = "${var.environment}-admin-role"

  create_login_profile    = true
  password_reset_required = true
  create_access_key       = true

  admin_role_trusted_services = [
    "ec2.amazonaws.com",
    "lambda.amazonaws.com",
    "ecs-tasks.amazonaws.com"
  ]

  create_instance_profile = true
  max_session_duration    = 43200

  # MFA Settings - Set to false initially to allow user to set up MFA
  # After user has MFA enabled, change these to true and reapply
  require_mfa           = true
  enforce_mfa_for_users = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
