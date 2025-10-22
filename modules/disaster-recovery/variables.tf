variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-learning"
}

# Multi-region DR variables
variable "dr_region" {
  description = "AWS region for disaster recovery"
  type        = string
  default     = "eu-west-1" # Example: Use Ireland as DR region if primary is us-east-1
}

variable "dr_vpc_cidr" {
  description = "CIDR block for the DR VPC"
  type        = string
  default     = "10.1.0.0/16" # Different from primary VPC CIDR
}

variable "aws_region" {
  description = "Primary AWS region"
  type        = string
}

variable "dns_zone_name" {
  description = "Route 53 hosted zone name"
  type        = string
  default     = "example.com"
}

variable "application_domain" {
  description = "Domain name for the application"
  type        = string
  default     = "app.example.com"
}

variable "primary_endpoint_domain" {
  description = "Endpoint domain for the primary region"
  type        = string
  default     = "primary-alb.us-east-1.elb.amazonaws.com"
}

variable "dr_endpoint_domain" {
  description = "Endpoint domain for the DR region"
  type        = string
  default     = "dr-alb.eu-west-1.elb.amazonaws.com"
}

variable "primary_dns_zone_id" {
  description = "Route 53 hosted zone ID for primary ALB"
  type        = string
  default     = "Z35SXDOTRQ7X7K" # Replace with correct value for your ALB
}

variable "dr_dns_zone_id" {
  description = "Route 53 hosted zone ID for DR ALB"
  type        = string
  default     = "Z32O12XQLNTSW2" # Replace with correct value for your DR ALB
}

variable "primary_alb_name" {
  description = "Name of the primary region ALB for CloudWatch metrics"
  type        = string
  default     = "app/primary-alb/abcdef1234567890"
}
