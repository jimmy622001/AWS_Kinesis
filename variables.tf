variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "learning"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-learning"
}

# Security Variables
variable "rancher_bootstrap_password" {
  description = "Bootstrap password for Rancher"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
}

variable "rds_master_password" {
  description = "Master password for RDS"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
}

# Disaster Recovery Variables
variable "dr_region" {
  description = "AWS region for disaster recovery"
  type        = string
  default     = "us-west-2"
}

variable "dr_vpc_cidr" {
  description = "CIDR block for DR VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_zone_name" {
  description = "DNS zone name for the application"
  type        = string
  default     = "example.com"
}

variable "application_domain" {
  description = "Main application domain name"
  type        = string
  default     = "app.example.com"
}

variable "primary_endpoint_domain" {
  description = "Primary region endpoint domain"
  type        = string
  default     = "primary.app.example.com"
}

variable "dr_endpoint_domain" {
  description = "DR region endpoint domain"
  type        = string
  default     = "dr.app.example.com"
}

variable "primary_dns_zone_id" {
  description = "Route53 zone ID for primary region"
  type        = string
  default     = ""
}

variable "dr_dns_zone_id" {
  description = "Route53 zone ID for DR region"
  type        = string
  default     = ""
}

variable "primary_alb_name" {
  description = "Name of the primary ALB"
  type        = string
  default     = "primary-alb"
}

# Network Variables
variable "customer_gateway_ip" {
  description = "Public IP address for customer gateway"
  type        = string
  default     = "203.0.113.12"
}

variable "onpremises_cidr" {
  description = "On-premises network CIDR"
  type        = string
  default     = "192.168.1.0/24"
}

# EKS Variables
variable "eks_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 4
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 1
}
