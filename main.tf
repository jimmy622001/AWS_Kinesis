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
module "secrets" {
  source = "./modules/secrets"

  project_name               = var.project_name
  rancher_bootstrap_password = var.rancher_bootstrap_password
  grafana_admin_password     = var.grafana_admin_password
  rds_master_password        = var.rds_master_password
}

module "networking" {
  source = "./modules/networking"

  vpc_cidr            = var.vpc_cidr
  azs                 = local.azs
  project_name        = var.project_name
  customer_gateway_ip = var.customer_gateway_ip
  onpremises_cidr     = var.onpremises_cidr
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

module "disaster_recovery" {
  source = "./modules/disaster-recovery"

  vpc_id             = module.networking.vpc_id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = module.networking.private_subnet_ids
  kms_key_arn        = module.security.kms_key_id
  project_name       = var.project_name
}

module "observability" {
  source = "./modules/observability"

  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  ecs_cluster_id         = module.containers.ecs_cluster_id
  ecs_execution_role_arn = module.security.ecs_execution_role_arn
  ecs_task_role_arn      = module.security.ecs_task_role_arn
  alb_security_group_id  = module.security.alb_security_group_id
  alb_listener_arn       = module.containers.alb_listener_arn
  project_name           = var.project_name
}