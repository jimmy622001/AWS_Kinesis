variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EKS"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-learning"
}