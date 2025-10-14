# AWS Learning Environment - Main Configuration
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
      Environment = "learning"
      Project     = "aws-skills-development"
      ManagedBy   = "terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  account_id = data.aws_caller_identity.current.account_id
  azs        = slice(data.aws_availability_zones.available.names, 0, 2)
}

# Module calls for different learning areas
module "networking" {
  source = "./modules/networking"

  vpc_cidr = var.vpc_cidr
  azs      = local.azs
}

module "security" {
  source = "./modules/security"

  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
}

module "serverless" {
  source = "./modules/serverless"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  lambda_role_arn    = module.security.lambda_role_arn
  project_name       = var.project_name
}

module "containers" {
  source = "./modules/containers"

  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_subnet_ids     = module.networking.private_subnet_ids
  security_group_id      = module.security.ecs_security_group_id
  ecs_execution_role_arn = module.security.ecs_execution_role_arn
  ecs_task_role_arn      = module.security.ecs_task_role_arn
  project_name           = var.project_name
}

module "event_systems" {
  source = "./modules/event-systems"

  project_name = var.project_name
}

module "cicd" {
  source = "./modules/cicd"

  project_name = var.project_name
}

module "monitoring" {
  source = "./modules/monitoring"

  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
}