variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-learning"
}