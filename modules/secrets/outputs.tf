output "rancher_password_arn" {
  description = "ARN of Rancher password secret"
  value       = aws_secretsmanager_secret.rancher_password.arn
}

output "grafana_password_arn" {
  description = "ARN of Grafana password secret"
  value       = aws_secretsmanager_secret.grafana_password.arn
}

output "rds_password_arn" {
  description = "ARN of RDS password secret"
  value       = aws_secretsmanager_secret.rds_password.arn
}
