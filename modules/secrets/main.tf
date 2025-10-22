# AWS Secrets Manager for sensitive values
resource "aws_secretsmanager_secret" "rancher_password" {
  name        = "${var.project_name}-rancher-password"
  description = "Bootstrap password for Rancher management"

  tags = {
    Name = "${var.project_name}-rancher-password"
  }
}

resource "aws_secretsmanager_secret_version" "rancher_password" {
  secret_id     = aws_secretsmanager_secret.rancher_password.id
  secret_string = var.rancher_bootstrap_password
}

resource "aws_secretsmanager_secret" "grafana_password" {
  name        = "${var.project_name}-grafana-password"
  description = "Admin password for Grafana"

  tags = {
    Name = "${var.project_name}-grafana-password"
  }
}

resource "aws_secretsmanager_secret_version" "grafana_password" {
  secret_id     = aws_secretsmanager_secret.grafana_password.id
  secret_string = var.grafana_admin_password
}

resource "aws_secretsmanager_secret" "rds_password" {
  name        = "${var.project_name}-rds-password"
  description = "Master password for RDS database"

  tags = {
    Name = "${var.project_name}-rds-password"
  }
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = var.rds_master_password
}
