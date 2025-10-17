variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "rancher_bootstrap_password" {
  description = "Bootstrap password for Rancher"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "rds_master_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}