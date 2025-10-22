variable "vpc_id" {
  description = "VPC ID for flow logs"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-learning"
}
